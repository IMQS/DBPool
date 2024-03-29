# docker build -t imqs/dbpool:master .

FROM imqs/ubuntu-base AS BUILD

RUN apt-get update && \
	apt-get install -y \
	build-essential \
	pkg-config \
	libevent-dev \
	pandoc \
	libtool \
	m4 \
	automake \
	libssl-dev

COPY pgbouncer /pgbouncer
WORKDIR /pgbouncer
RUN ./autogen.sh && \
	./configure --enable-evdns=no && \
	make -j install

FROM imqs/ubuntu-base

RUN apt-get update && \
	apt-get install -y libevent-2.1-6

RUN groupadd -g 999 appuser && \
	useradd -r -u 999 -g appuser appuser

# Serves as the local working directory for pid and log files.
RUN mkdir /deploy && chmod o+rwx /deploy
COPY --from=BUILD /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

COPY pgbouncer.ini users.txt /config/

USER appuser

ENTRYPOINT ["/usr/local/bin/pgbouncer", "/config/pgbouncer.ini"]
