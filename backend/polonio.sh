#!/usr/bin/env bash

UNAMEOUT="$(uname -s)"

# Verify operating system is supported...
case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    *)                  MACHINE="UNKNOWN"
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "Unsupported operating system [$(uname -s)]. Polonio dev box supports macOS, Linux, and Windows (WSL2)." >&2
    exit 1
fi

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        NC="$(tput sgr0)"
    fi
fi

# Function that prints the available commands...
function display_help {
    echo "Polonio"
    echo
    echo "${YELLOW}Usage:${NC}" >&2
    echo "  polonio COMMAND [options] [arguments]"
    echo
    echo "Unknown commands are passed to docker compose."
    echo
    echo "${YELLOW}docker compose Commands:${NC}"
    echo "  ${GREEN}polonio up${NC}        Start the application"
    echo "  ${GREEN}polonio up -d${NC}     Start the application in the background"
    echo "  ${GREEN}polonio stop${NC}      Stop the application"
    echo "  ${GREEN}polonio restart${NC}   Restart the application"
    echo "  ${GREEN}polonio ps${NC}        Display the status of all containers"
    echo "  ${GREEN}polonio rebuild${NC}   Rebuild all Polonio containers (no cache)"
    echo
    echo "${YELLOW}Artisan Commands:${NC}"
    echo "  ${GREEN}polonio artisan ...${NC}   Run an Artisan command"
    echo "  ${GREEN}polonio artisan queue:work${NC}"
    echo
    echo "${YELLOW}PHP Commands:${NC}"
    echo "  ${GREEN}polonio php ...${NC}       Run a snippet of PHP code"
    echo "  ${GREEN}polonio php -v${NC}"
    echo
    echo "${YELLOW}Composer Commands:${NC}"
    echo "  ${GREEN}polonio composer ...${NC}  Run a Composer command"
    echo "  ${GREEN}polonio composer require laravel/sanctum${NC}"
    echo
    echo "${YELLOW}Node Commands:${NC}"
    echo "  ${GREEN}polonio node ...${NC}      Run a Node command"
    echo "  ${GREEN}polonio node --version${NC}"
    echo "${YELLOW}NPM Commands:${NC}"
    echo "  ${GREEN}polonio npm ...${NC}       Run a npm command"
    echo "  ${GREEN}polonio npx${NC}           Run a npx command"
    echo "  ${GREEN}polonio npm run prod${NC}"
    echo
    echo "${YELLOW}Database Commands:${NC}"
    echo "  ${GREEN}polonio mysql${NC}     Start a MySQL CLI session within the 'mysql' container"
    echo "  ${GREEN}polonio mariadb${NC}   Start a MySQL CLI session within the 'mariadb' container"
    echo "  ${GREEN}polonio psql${NC}      Start a PostgreSQL CLI session within the 'pgsql' container"
    echo "  ${GREEN}polonio redis${NC}     Start a Redis CLI session within the 'redis' container"
    echo
    echo "${YELLOW}Debugging:${NC}"
    echo "  ${GREEN}polonio debug ...${NC}     Run an Artisan command in debug mode"
    echo "  ${GREEN}polonio debug queue:work${NC}"
    echo
    echo "${YELLOW}Running Tests:${NC}"
    echo "  ${GREEN}polonio test${NC}          Run the PHPUnit tests via the Artisan test command"
    echo "  ${GREEN}polonio phpunit ...${NC}   Run PHPUnit"
    echo
    echo "${YELLOW}Container CLI:${NC}"
    echo "  ${GREEN}polonio bash${NC}          Alias for 'polonio shell'"
    echo "  ${GREEN}polonio root-bash${NC}     Alias for 'polonio root-shell'"
    echo "  ${GREEN}polonio tinker${NC}        Start a new Laravel Tinker session"
    echo
    echo "${YELLOW}Sharing:${NC}"
    echo "  ${GREEN}polonio share${NC}     Share the application publicly via a temporary URL"
    echo
    echo "${YELLOW}Binaries:${NC}"
    echo "  ${GREEN}polonio bin ...${NC}   Run Composer binary scripts from the vendor/bin directory"

    exit 1
}

# Proxy the "help" command...
if [ $# -gt 0 ]; then
    if [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "-help" ] || [ "$1" == "--help" ]; then
        display_help
    fi
else
    display_help
fi

# Source the ".env" file so Laravel's environment variables are available...
if [ ! -z "$APP_ENV" ] && [ -f ./.env.$APP_ENV ]; then
  source ./.env.$APP_ENV;
elif [ -f ./.env ]; then
  source ./.env;
fi

# Source the docker .env file variables...
if [ -f ./.env.docker ]; then
  source ./.env.docker;
fi

# Define environment variables...
export APP_PORT=${APP_PORT:-80}
export APP_SERVICE=${APP_SERVICE:-"app"}
export DB_PORT=${DB_PORT:-3306}
export WWWUSER=${WWWUSER:-$UID}
export WWWGROUP=${WWWGROUP:-$(id -g)}

# Docker images...
export DOCKER_IMAGE_PHP=${DOCKER_IMAGE_PHP:-"php:8.1-fpm"}
export DOCKER_IMAGE_MYSQL=${DOCKER_IMAGE_MYSQL:-"mysql/mysql:5.7"}

# Package versions...
export DOCKER_COMPOSER_VERSION=${DOCKER_COMPOSER_VERSION:-"composer:2.8.1"}
export DOCKER_NODE_VERSION=${DOCKER_NODE_VERSION:-"lts"}
export DOCKER_XDEBUG_VERSION=${DOCKER_XDEBUG_VERSION:-"xdebug-2.9.8"}

# Polonio vars...
export LETTERHEAD_FILES=${LETTERHEAD_FILES:-""}
export LETTERHEAD_SHARE_DASHBOARD=${LETTERHEAD_SHARE_DASHBOARD:-4040}
export LETTERHEAD_SHARE_SERVER_HOST=${LETTERHEAD_SHARE_SERVER_HOST:-"polonio.site"}
export LETTERHEAD_SHARE_SERVER_PORT=${LETTERHEAD_SHARE_SERVER_PORT:-8080}
export LETTERHEAD_SHARE_SUBDOMAIN=${LETTERHEAD_SHARE_SUBDOMAIN:-""}

# Function that outputs Sail is not running...
function letterhead_is_not_running {
    echo "${BOLD}Polonio is not running.${NC}" >&2
    echo "" >&2
    echo "${BOLD}You may run Polonio using the following command(s):${NC} './polonio up' or './polonio up -d'" >&2
    exit 1
}

# Define Docker Compose command prefix...
docker compose &> /dev/null
if [ $? == 0 ]; then
    DOCKER_COMPOSE=(docker compose)
else
    DOCKER_COMPOSE=(docker-compose)
fi

if [ -n "$LETTERHEAD_FILES" ]; then
    # Convert LETTERHEAD_FILES to an array...
    IFS=':' read -ra LETTERHEAD_FILES <<< "$LETTERHEAD_FILES"

    for FILE in "${LETTERHEAD_FILES[@]}"; do
        if [ -f "$FILE" ]; then
            DOCKER_COMPOSE+=(-f "$FILE")
        else
            echo "${BOLD}Unable to find Docker Compose file: '${FILE}'${NC}" >&2

            exit 1
        fi
    done
fi

EXEC="yes"

if [ -z "$LETTERHEAD_SKIP_CHECKS" ]; then
    # Ensure that Docker is running...
    if ! docker info > /dev/null 2>&1; then
        echo "${BOLD}Docker is not running.${NC}" >&2

        exit 1
    fi

    # Determine if Polonio is currently up...
    if "${DOCKER_COMPOSE[@]}" ps "$APP_SERVICE" 2>&1 | grep 'Exit\|exited'; then
        echo "${BOLD}Shutting down old Polonio processes...${NC}" >&2

        "${DOCKER_COMPOSE[@]}" down > /dev/null 2>&1

        EXEC="no"
    elif [ -z "$("${DOCKER_COMPOSE[@]}" ps -q)" ]; then
        EXEC="no"
    fi
fi

ARGS=()

if [ "$1" == "install" ]; then

  echo "Installing Polonio Application..."

  exit 1

# Proxy PHP commands to the "php" binary on the application container...
elif [ "$1" == "php" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "php" "$@")
    else
        letterhead_is_not_running
    fi

# Proxy vendor binary commands on the application container...
elif [ "$1" == "bin" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" ./vendor/bin/"$@")
    else
        letterhead_is_not_running
    fi

# Proxy docker-compose commands to the docker-compose binary on the application container...
elif [ "$1" == "docker-compose" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "${DOCKER_COMPOSE[@]}")
    else
        letterhead_is_not_running
    fi

# Proxy Composer commands to the "composer" binary on the application container...
elif [ "$1" == "composer" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" "composer" "$@")
    else
        letterhead_is_not_running
    fi

# Proxy Artisan commands to the "artisan" binary on the application container...
elif [ "$1" == "artisan" ] || [ "$1" == "art" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan "$@")
    else
        letterhead_is_not_running
    fi

# Proxy the "debug" command to the "php artisan" binary on the application container with xdebug enabled...
elif [ "$1" == "debug" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u polonio -e XDEBUG_SESSION=1)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan "$@")
    else
        letterhead_is_not_running
    fi

# Proxy the "test" command to the "php artisan test" Artisan command...
elif [ "$1" == "test" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan test "$@")
    else
        letterhead_is_not_running
    fi

# Proxy the "phpunit" command to "php vendor/bin/phpunit"...
elif [ "$1" == "phpunit" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php vendor/bin/phpunit "$@")
    else
        letterhead_is_not_running
    fi

# Initiate a Laravel Tinker session within the application container...
elif [ "$1" == "tinker" ] ; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" php artisan tinker)
    else
        letterhead_is_not_running
    fi

# Proxy Node commands to the "node" binary on the application container...
elif [ "$1" == "node" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" node "$@")
    else
        letterhead_is_not_running
    fi

# Proxy NPM commands to the "npm" binary on the application container...
elif [ "$1" == "npm" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" npm "$@")
    else
        letterhead_is_not_running
    fi

# Proxy NPX commands to the "npx" binary on the application container...
elif [ "$1" == "npx" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" npx "$@")
    else
        letterhead_is_not_running
    fi

# Initiate a MySQL CLI terminal session within the "mysql" container...
elif [ "$1" == "mysql" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(mysql bash -c)
        ARGS+=("MYSQL_PWD=\${MYSQL_PASSWORD} mysql -u \${MYSQL_USER} \${MYSQL_DATABASE}")
    else
        letterhead_is_not_running
    fi

# Initiate a MySQL CLI terminal session within the "mariadb" container...
elif [ "$1" == "mariadb" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(mariadb bash -c)
        ARGS+=("MYSQL_PWD=\${MYSQL_PASSWORD} mysql -u \${MYSQL_USER} \${MYSQL_DATABASE}")
    else
        letterhead_is_not_running
    fi

# Initiate a PostgreSQL CLI terminal session within the "pgsql" container...
elif [ "$1" == "psql" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(pgsql bash -c)
        ARGS+=("PGPASSWORD=\${PGPASSWORD} psql -U \${POSTGRES_USER} \${POSTGRES_DB}")
    else
        letterhead_is_not_running
    fi

# Initiate a Bash shell within the application container...
elif [ "$1" == "shell" ] || [ "$1" == "bash" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec -u root)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" bash "$@")
    else
        letterhead_is_not_running
    fi

# Initiate a root user Bash shell within the application container...
elif [ "$1" == "root-shell" ] || [ "$1" == "root-bash" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=("$APP_SERVICE" bash "$@")
    else
        letterhead_is_not_running
    fi

# Initiate a Redis CLI terminal session within the "redis" container...
elif [ "$1" == "redis" ] ; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        ARGS+=(exec)
        [ ! -t 0 ] && ARGS+=(-T)
        ARGS+=(redis redis-cli)
    else
        letterhead_is_not_running
    fi

# Share the site...
elif [ "$1" == "share" ]; then
    shift 1

    if [ "$EXEC" == "yes" ]; then
        docker run --init --rm -p "$LETTERHEAD_SHARE_DASHBOARD":4040 -t beyondcodegmbh/expose-server:latest share http://host.docker.internal:"$APP_PORT" \
            --server-host="$LETTERHEAD_SHARE_SERVER_HOST" \
            --server-port="$LETTERHEAD_SHARE_SERVER_PORT" \
            --auth="$LETTERHEAD_SHARE_TOKEN" \
            --subdomain="$LETTERHEAD_SHARE_SUBDOMAIN" \
            "$@"

        exit
    else
        letterhead_is_not_running
    fi

# Initiate a Redis CLI terminal session within the "redis" container...
elif [ "$1" == "rebuild" ]; then
    echo "${BOLD}Rebuilding Polonio container(s) from scratch (no cache)...${NC}" >&2

    ARGS+=(build --no-cache)

# Pass unknown commands to the "docker-compose" binary...
else
    ARGS+=("$@")
fi

# Run Docker Compose with the defined arguments...
"${DOCKER_COMPOSE[@]}" "${ARGS[@]}"