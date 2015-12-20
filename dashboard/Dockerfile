FROM python:latest

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone https://github.com/macalik/TITDev.git .
RUN pip install --no-cache-dir -r docker_req.txt
# COPY base.json configs/base.json