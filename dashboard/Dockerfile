FROM python:latest
MAINTAINER Kazuki Ishikawa <jamesrhit-titdev@yahoo.com>

ENV DASHBOARD_DOCKER_VERSION 1.0.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone https://github.com/tritanium-industries/TITDev.git .
RUN pip install --no-cache-dir -r requirements.txt
# Monkey patch flask_pymongo forking (https://github.com/dcrosta/flask-pymongo/pull/67)
COPY __init__.py /usr/local/lib/python3.5/site-packages/flask_pymongo/__init__.py

# OS tools
RUN apt-get update && apt-get install -y vim supervisor
RUN mkdir -p /var/log/supervisord /var/log/celery /var/run /var/log/uwsgi
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY base.json configs/base.json
COPY uwsgi.ini uwsgi.ini

EXPOSE 3031

VOLUME /usr/src/app/static

ENTRYPOINT ["supervisord"]
CMD ["-n -c /etc/supervisor/conf.d/supervisord.conf"]