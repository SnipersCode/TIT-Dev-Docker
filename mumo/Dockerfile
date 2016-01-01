FROM debian:latest

RUN apt-get update && apt-get install -y \
  git-core \
  python-zeroc-ice \
  python-daemon
RUN mkdir -p /usr/share/slice
COPY Murmur.ice /usr/share/slice/Murmur.ice

RUN cd /etc/ && git clone https://github.com/mumble-voip/mumo.git
WORKDIR /etc/mumo
COPY AuthSticky.ini modules-available/AuthSticky.ini
COPY AuthSticky.py modules/AuthSticky.py
RUN mkdir modules-enabled && cd modules-enabled && \
  ln -s ../modules-available/seen.ini && \
  ln -s ../modules-available/AuthSticky.ini
COPY mumo.ini mumo.ini
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 50983

ENTRYPOINT ["python", "mumo.py"]
CMD ["-a"]