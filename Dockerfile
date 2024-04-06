FROM ubuntu:22.04 as builder

RUN apt update && apt upgrade -y && apt install make gcc pkg-config git libssl-dev -y
RUN git clone https://github.com/valkey-io/valkey.git /valkey
RUN rm -rf /var/lib/apt/lists/*
WORKDIR /valkey
RUN make install
RUN sed -i 's/bind 127.0.0.1 -::1/bind * -::*/g' /valkey/valkey.conf

FROM gcr.io/distroless/base-debian12:latest
COPY --from=builder /usr/local/bin/valkey-* /usr/local/bin/
COPY --from=builder /valkey/valkey.conf /etc/valkey/valkey.conf

WORKDIR /data
EXPOSE 6379
CMD ["/usr/local/bin/valkey-server", "/etc/valkey/valkey.conf"]
