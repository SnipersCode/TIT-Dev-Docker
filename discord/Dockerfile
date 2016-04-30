FROM python:latest
MAINTAINER Kazuki Ishikawa <jamesrhit-titdev@yahoo.com>

ENV DISCORD_DOCKER_VERSION 1.0.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN git clone https://github.com/tritanium-industries/TITDev-Discord.git .
RUN pip install --no-cache-dir -r requirements.txt

# OS tools
RUN apt-get update && apt-get install -y vim

CMD ["python", "-u", "./main.py"]