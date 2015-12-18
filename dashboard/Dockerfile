FROM python:latest

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone git@github.com:macalik/TITDev.git
RUN pip install --no-cache-dir -r requirements.txt