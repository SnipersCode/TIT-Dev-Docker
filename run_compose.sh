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
docker network connect titdevdocker discourse
docker-compose --x-networking up -d

# wait for database, then execute init changes to database
until docker exec titdev_database sh -c 'mongo < /scripts/users_add.txt'
do
    sleep 2
    echo "Could not connect to database. Retrying... (Use Ctrl-C to stop trying)."
done
docker exec titdev_murmur sh -c '/opt/murmur/murmur.x86 -supw $RANDOM_PASSWORD'