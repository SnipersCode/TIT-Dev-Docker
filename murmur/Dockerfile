FROM busybox:latest

# Download statically compiled murmur and install it to /opt/murmur
ADD https://github.com/mumble-voip/mumble/releases/download/1.2.12/murmur-static_x86-1.2.12.tar.bz2 /opt/
RUN bzcat /opt/murmur-static_x86-1.2.12.tar.bz2 | tar -x -C /opt -f - && \
    rm /opt/murmur-static_x86-1.2.12.tar.bz2 && \
    mv /opt/murmur-static_x86-1.2.12 /opt/murmur

# Copy in our slightly tweaked INI which points to our volume
COPY murmur.ini /etc/murmur.ini

# Forward apporpriate ports
EXPOSE 64738/tcp 64738/udp 6502

VOLUME ["/data/murmur"]

# Run murmur
ENTRYPOINT ["/opt/murmur/murmur.x86", "-ini", "/etc/murmur.ini"]
CMD ["-fg", "-v"]