#!/usr/bin/env bash

# Make sure script is run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (or sudo)"
    exit 1
fi

# install discourse
if [ ! -d forum/ ]; then
    FIRST=1
    mkdir -p forum/
    git clone https://github.com/discourse/discourse_docker.git forum/
    cp settings/discourse.yml forum/containers/discourse.yml
    cd forum/
    ./launcher bootstrap discourse
    ./launcher start discourse
else
    FIRST=0
    cp settings/discourse.yml forum/containers/discourse.yml
    cd forum/
    ./launcher rebuild discourse
fi

# build and start docker image
docker-compose stop
docker-compose build --no-cache

# wait for database, then execute init changes to database
if [ "$FIRST" -eq 1 ]; then
    docker network create titdev-network
    docker network connect titdev-network discourse
    docker-compose up -d dbdata database murmur
    until docker exec titdev-database sh -c 'mongo < /scripts/admin_add.txt'
    do
        sleep 5
        echo "Could not connect to database. Retrying... (Use Ctrl-C to stop trying)."
    done
    sleep 5
    docker-compose up -d dashboard mumo
    docker exec titdev-database sh -c 'mongo < /scripts/users_add.txt'
    sleep 5
    docker-compose up -d nginx
else
    docker network connect titdev-network discourse
    docker-compose up -d dbdata database murmur
    until docker exec titdev-database sh -c 'mongo < /scripts/users_add.txt'
    do
        sleep 5
        echo "Could not connect to database. Retrying... (Use Ctrl-C to stop trying)."
    done
    sleep 5
    docker-compose up -d dashboard mumo
    sleep 5
    docker-compose up -d nginx
fi
docker exec titdev-murmur sh -c '/opt/murmur/murmur.x86 -supw $RANDOM_PASSWORD'