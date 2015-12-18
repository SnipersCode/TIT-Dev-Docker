FROM mongo:latest

ONBUILD COPY users_add.txt /data/db/scripts/users_add.txt
ONBUILD RUN mongo < /data/db/scripts/users_add.txt