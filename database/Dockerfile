FROM mongo:latest

RUN mkdir -p /data/db/scripts
COPY users_add.txt /data/db/scripts/users_add.txt
RUN mongo < /data/db/scripts/users_add.txt