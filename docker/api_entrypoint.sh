#!/bin/sh
set -e

: "${HP_TEST:=6281222452573}"
: "${ENVIRONMENT_HOST:=development}"
: "${API_DB_HOST:=mysql}"
# if we're linked to MySQL and thus have credentials already, let's use them
: ${API_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
if [ "$API_DB_USER" = 'root' ]; then
    : ${API_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${API_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
: ${API_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-api_dev}}

if [ -z "$API_DB_PASSWORD" ]; then
    echo >&2 'error: missing required API_DB_PASSWORD environment variable'
    echo >&2 '  Did you forget to -e API_DB_PASSWORD=... ?'
    echo >&2
    echo >&2 '  (Also of interest might be API_DB_USER and API_DB_NAME.)'
    exit 1
fi

sed_escape_lhs() {
    echo "$@" | sed 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
    echo "$@" | sed 's/[\/&]/\\&/g'
}
php_escape() {
    php -r 'var_export(('$2') $argv[1]);' "$1"
}
set_config() {
    key="$1"
    value="$2"
    var_type="${3:-string}"
    sed -ri "/"$key"/s/'[^']*'/"$(php_escape "$value" "$var_type")"/2" /usr/share/nginx/html/api-config/settings.php
}

set_config 'API_DB_HOST' "$API_DB_HOST"
set_config 'API_DB_USER' "$API_DB_USER"
set_config 'API_DB_PASSWORD' "$API_DB_PASSWORD"
set_config 'API_DB_NAME' "$API_DB_NAME"
set_config 'ENVIRONMENT_HOST' "$ENVIRONMENT_HOST"
set_config 'HP_TEST' "$HP_TEST"

#chown -R nobody /usr/share/nginx/html/log

nginx
exec "$@"