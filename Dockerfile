# docker build -t imqs/dbpool:master .

FROM imqs/ubuntu-base:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y \
		build-essential \
		pkg-config \
		libevent-dev \
		pandoc \
		libtool \
		m4 \
		automake \
		libssl-dev \
		python3 \
	&& rm -rf /var/lib/apt/lists/*

COPY pgbouncer /pgbouncer
WORKDIR /pgbouncer
RUN ./autogen.sh && \
	./configure --enable-evdns=no && \
	make -j install

FROM imqs/ubuntu-base:20.04

RUN apt-get update \
	&& apt-get install -y libevent-2.1-7 \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd -g 999 appuser && \
	useradd -r -u 999 -g appuser appuser

# Serves as the local working directory for pid and log files.
RUN mkdir /deploy && chmod o+rwx /deploy
COPY --from=build /usr/local/bin/pgbouncer /usr/local/bin/pgbouncer

COPY pgbouncer.ini users.txt /config/

USER appuser

ARG PGBOUNCER_USER="test_user"

HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD psql -p 6432 -U "$PGBOUNCER_USER" -d pgbouncer -c "SHOW USERS" >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/pgbouncer", "/config/pgbouncer.ini"]
