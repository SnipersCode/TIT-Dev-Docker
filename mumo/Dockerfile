FROM debian:latest

RUN apt-get update && apt-get install -y \
  git-core \
  python-zeroc-ice \
  python-daemon
RUN mkdir -p /usr/share/slice
COPY Murmur.ice /usr/share/slice/Murmur.ice

RUN git clone https://github.com/mumble-voip/mumo.git && cd mumo
RUN mkdir modules-enabled && cd modules-enabled && \
  ln -s ../modules-available/test.ini && cd ..

ENTRYPOINT ["python", "mumo.py"]
CMD ["-a"]