#!/usr/bin/env bash

# install discourse
if [ ! -d forum/ ]; then
    mkdir -p forum/
    git clone https://github.com/discourse/discourse_docker.git forum/
    cp settings/discourse.yml forum/containers/discourse.yml
    cd forum/
    ./launcher bootstrap discourse
    ./launcher start discourse
fi

# build and start docker image
docker-compose stop
docker-compose build
docker-compose up -d

# wait for database, then execute init changes to database
docker inspect --format '{{ .NetworkSettings.IPAddress }}:27017' titdevdocker_database_1 | \
xargs wget --retry-connrefused --tries=5 -q --wait=1 --spider
docker exec titdevdocker_database_1 sh -c 'mongo < /scripts/users_add.txt'