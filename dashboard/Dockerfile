FROM python:latest
MAINTAINER Kazuki Ishikawa <jamesrhit-titdev@yahoo.com>

ENV DASHBOARD_DOCKER_VERSION 1.0.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone https://github.com/macalik/TITDev.git .
COPY docker_req.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
# Monkey patch flask_pymongo forking (https://github.com/dcrosta/flask-pymongo/pull/67)
COPY __init__.py /usr/local/lib/python3.5/site-packages/flask_pymongo/__init__.py

COPY base.json configs/base.json
COPY uwsgi.ini uwsgi.ini

EXPOSE 3031

VOLUME /usr/src/app/static

ENTRYPOINT ["uwsgi"]
CMD ["--ini", "uwsgi.ini"]