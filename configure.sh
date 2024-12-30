#!/usr/bin/env bash


SUPPORTED_MOODLE_VERSIONS=("3.11" "4.0" "4.1" "4.2" "4.3" "4.4" "4.5")
SUPPORTED_DBMS=("mysql" "postgres")

MOODLE_GIT_URL="git://git.moodle.org/moodle.git"

show_help() {
  echo "Usage: $(basename $0) [OPTIONS]"
  echo "Options:"
  echo "  -h, --help    Display this help message"
  echo "  -m, --moodle  Moodle version (supported versions: $(IFS=, ; echo "${SUPPORTED_MOODLE_VERSIONS[*]}"))"
  echo "  -d, --dbms    DBMS (supported DBMS: $(IFS=, ; echo "${SUPPORTED_DBMS[*]}"))"
}

generate_start_script() {
  echo "#!/bin/bash
    docker compose up -d --build $1 $2" > start.sh
  chmod +x start.sh
}

generate_stop_script() {
  echo "#!/bin/bash
    docker compose down" > stop.sh
  chmod +x stop.sh
}

make_config_php() {
  echo ""
  echo "Making config.php..."
  until docker compose exec $PHP_SERVICE \
            php /var/www/html/moodle/admin/cli/install.php --skip-database --non-interactive \
            --wwwroot="http://$MOODLE_HOST:$MOODLE_PORT" \
            --dbtype=$MOODLE_DB_TYPE \
            --dbhost=$DBMS \
            --dbuser=$DB_USER \
            --dbpass=$DB_PASSWORD \
            --dbport=$DB_INTERNAL_PORT > /dev/null 2>&1
  do
      ((c++)) && ((c==30)) && { echo "Failed to create config.php!"; exit 1; }
      sleep 1
  done
  echo "config.php created successfully"
}

composer_install() {
  echo ""
  echo "Running composer install..."
  docker compose exec -w /var/www/html/moodle $PHP_SERVICE composer install || { echo "composer install failed!"; exit 1; }
}

prepare_moodle_directory() {
  {
    (
      echo "Trying to find existing Moodle directory..."
      cd "moodle" > /dev/null 2>&1 || { echo "Moodle directory not found"; exit 1; }

      {
        git fetch &&
        git reset --hard "origin/$1" &&
        git clean -fdx
      } > /dev/null 2>&1 || { echo "Moodle directory seems to be corrupted"; exit 1; }


    ) || (
      rm -rf moodle/

      echo "Downloading Moodle..."
      git clone -b "$MOODLE_GIT_BRANCH" "$MOODLE_GIT_URL" || { echo "Failed to download Moodle!"; exit 1; }
    )
  } && echo "Moodle directory is ready to use!" || exit 1
}


cd "$(dirname "$0")" || exit 1


VALID_ARGS=$(getopt -o hm:d: --long help,moodle:,dbms: -- "$@")
if [[ $? -ne 0 ]]; then
    show_help
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -h | --help)
        show_help
        exit 0
        ;;
    -m | --moodle)
        MOODLE_VERSION=$2
        shift 2
        ;;
    -d | --dbms)
        DBMS=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done

if [ -z "$MOODLE_VERSION" ]; then
    echo "You should specify Moodle version"
    show_help
    exit 1;
fi

if [ -z "$DBMS" ]; then
    echo "You should specify DBMS"
    show_help
    exit 1;
fi

if ! [[ ${SUPPORTED_MOODLE_VERSIONS[*]} =~ $MOODLE_VERSION ]]; then
    echo "Invalid Moodle version: $MOODLE_VERSION"
    show_help
    exit 1;
fi

if ! [[ ${SUPPORTED_DBMS[*]} =~ $DBMS ]]; then
    echo "Invalid DBMS: $DBMS"
    show_help
    exit 1;
fi


source .env

case "$MOODLE_VERSION" in
  "3.11") MOODLE_GIT_BRANCH="MOODLE_311_STABLE" PHP_SERVICE="php80";;
  "4.0") MOODLE_GIT_BRANCH="MOODLE_400_STABLE" PHP_SERVICE="php80";;
  "4.1") MOODLE_GIT_BRANCH="MOODLE_401_STABLE" PHP_SERVICE="php80";;
  "4.2") MOODLE_GIT_BRANCH="MOODLE_402_STABLE" PHP_SERVICE="php80";;
  "4.3") MOODLE_GIT_BRANCH="MOODLE_403_STABLE" PHP_SERVICE="php80";;
  "4.4") MOODLE_GIT_BRANCH="MOODLE_404_STABLE" PHP_SERVICE="php83";;
  "4.5") MOODLE_GIT_BRANCH="MOODLE_405_STABLE" PHP_SERVICE="php83";;
esac

case "$DBMS" in
  "mysql") MOODLE_DB_TYPE="mysqli" DB_SERVICE="mysql" DB_INTERNAL_PORT=3306;;
  "postgres") MOODLE_DB_TYPE="pgsql" DB_SERVICE="postgres" DB_INTERNAL_PORT=5432;;
esac

echo "Selected Moodle version: $MOODLE_VERSION"
echo "Selected DBMS: $DBMS"
echo ""
echo "Database name: $DB_NAME"
echo "Database user: $DB_USER"
echo "Database password: $DB_PASSWORD"
echo "Database port: $DB_PORT"

docker compose down > /dev/null 2>&1

generate_start_script $PHP_SERVICE $DB_SERVICE
generate_stop_script

rm -rf moodledata/
mkdir moodledata/
prepare_moodle_directory $MOODLE_GIT_BRANCH

rm -rf db-data/

echo ""
echo "Running Docker Compose..."
./start.sh

make_config_php
composer_install

echo ""
echo "Docker development environment for Moodle is ready!"
echo "Moodle URL: http://$MOODLE_HOST:$MOODLE_PORT"
