#!/usr/bin/env bash

# Make sure script is run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (or sudo)"
    exit 1
fi

# install discourse
if [ ! -d forum/ ]; then
    mkdir -p forum/
    git clone https://github.com/discourse/discourse_docker.git forum/
    cp settings/discourse.yml forum/containers/discourse.yml
    cd forum/
    ./launcher bootstrap discourse
    ./launcher start discourse
else
    cp settings/discourse.yml forum/containers/discourse.yml
    cd forum/
    ./launcher rebuild discourse
fi

# build and start docker image
docker-compose stop
docker-compose build --no-cache
docker-compose up -d

# wait for database, then execute init changes to database
docker inspect --format '{{ .NetworkSettings.IPAddress }}:27017' titdevdocker_database_1 | \
xargs wget --retry-connrefused --tries=5 -q --wait=1 --spider
docker exec titdevdocker_database_1 sh -c 'mongo < /scripts/users_add.txt'