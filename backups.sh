#!/usr/bin/env bash

if [ "$#" -ne 3 ]; then
  echo "Requires three arguments."
  exit 1
fi

case "$1" in
  backup )
    case "$2" in
      all )
        echo "Backing up $2 to file $3"
        mkdir -p backups
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups:/backups ubuntu tar cvf /backups/$3.tar /data
        ;;
      database )
        echo "Backing up $2 to file $3"
        mkdir -p backups/database
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups/database:/backups ubuntu tar cvf /backups/$3.tar /data/db
        ;;
      murmur )
        echo "Backing up $2 to file $3"
        mkdir -p backups/murmur
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups/murmur:/backups ubuntu tar cvf /backups/$3.tar /data/murmur
        ;;
      * )
        echo "Not a valid container for backup"
        exit 1
        ;;
    esac
    ;;
  restore )
    case "$2" in
      all )
        echo "Restoring $2 from file $3"
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups:/backups ubuntu bash -c "rm -rf /data && cd / && tar xvf /backups/$3.tar"
        ;;
      database )
        echo "Restoring $2 from file $3"
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups/database:/backups ubuntu bash -c "rm -rf /data/db && cd / && tar xvf /backups/$3.tar"
        ;;
      murmur )
        echo "Restoring $2 from file $3"
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups/murmur:/backups ubuntu bash -c "rm -rf /data/murmur && cd / && tar xvf /backups/$3.tar"
        ;;
      * )
        echo "Not a valid container for restore"
        exit 1
        ;;
    esac
    ;;
  init )
    case "$2" in
      murmur )
        echo "Initializing $2 from file $3"
        docker run --volumes-from titdev-dbdata -v $(pwd)/backups:/backups ubuntu bash -c "cp /backups/$3 /data/murmur/murmur.sqlite"
        ;;
      nginx)
        echo "Initializing custom static files"
        docker-compose stop nginx
        docker-compose rm userdata nginx
        docker-compose build userdata
        docker-compose up -d userdata
        sleep 3
        docker-compose up -d nginx
        ;;
      * )
        echo "Not a valid container for init"
        exit 1
        ;;
    esac
    ;;
  * )
    echo "Option was invalid."
    exit 1
    ;;
esac