FROM busybox:latest

ENV MURMUR_VERSION 1.2.12

# Download statically compiled murmur and install it to /opt/murmur
ADD https://github.com/mumble-voip/mumble/releases/download/${MURMUR_VERSION}/murmur-static_x86-${MURMUR_VERSION}.tar.bz2 /opt/
RUN bzcat /opt/murmur-static_x86-${MURMUR_VERSION}.tar.bz2 | tar -x -C /opt -f - && \
    rm /opt/murmur-static_x86-${MURMUR_VERSION}.tar.bz2 && \
    mv /opt/murmur-static_x86-${MURMUR_VERSION} /opt/murmur

# Copy in our slightly tweaked INI which points to our volume
COPY murmur.ini /etc/murmur.ini

# Forward apporpriate ports
EXPOSE 64738/tcp 64738/udp 6502

VOLUME ["/data/murmur"]

# Run murmur
ENTRYPOINT ["/opt/murmur/murmur.x86", "-fg", "-v"]
CMD ["-ini", "/etc/murmur.ini"]