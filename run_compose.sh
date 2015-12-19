#!/usr/bin/env bash
docker-compose stop
docker-compose build
docker-compose up -d
docker exec titdevdocker_database_1 sh -c 'mongo < /scripts/users_add.txt'