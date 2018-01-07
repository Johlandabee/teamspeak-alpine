FROM frolvlad/alpine-glibc:latest

ARG BUILD_DATE
ARG VCS_REF

LABEL MAINTAINER="Johlandabee <contact@jlndbe.me>" \
    me.jlndbe.teamspeak-server-version=3.0.13.8 \
    org.label-schema.schema-version="1.0.0-rc1" \
    org.label-schema.name=${IMAGE_NAME} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.vcs-url="https://github.com/Johlandabee/teamspeak-alpine.git" \
    org.label-schema.vcs-ref=${VCS_REF}

ENV ARCH=amd64
ENV DOCKERIZE_VERSION=v0.6.0
ENV TEAMSPEAK_VERSION=3.0.13.8

ENV DOCKERIZE_SOURCE="https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-${ARCH}-${DOCKERIZE_VERSION}.tar.gz"
ENV TEAMSPEAK_SOURCE="http://dl.4players.de/ts/releases/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_${ARCH}-${TEAMSPEAK_VERSION}.tar.bz2"
# Network
ENV TS_NET_IP_VOICE=0.0.0.0 
ENV TS_NET_PORT_VOICE=9987 
ENV TS_NET_IP_FILETRANSFER=0.0.0.0
ENV TS_NET_PORT_FILETRANFER=30033 
ENV TS_NET_IP_SERVERQUERY=0.0.0.0 
ENV TS_NET_PORT_SERVERQUERY=10011
# Query white/blacklist
ENV TS_QUERY_IP_WHITELIST=query_ip_whitelist.txt
ENV TS_QUERY_IP_BLACKLIST=query_ip_blacklist.txt
# Database
ENV TS_DB_CLEAR_DATABASE=0
ENV TS_DB_PLUGIN=ts3db_sqlite3
ENV TS_DB_PLUGIN_PARAMETER=ts3db_mariadb.ini
ENV TS_DB_CONNECTIONS=10
ENV TS_DB_CLIENT_KEEP_DAYS=90
ENV TS_DB_LOG_KEEP_DAYS=90
ENV TS_DB_SQL_CREATE_PATH=create_mariadb/
ENV TS_DB_MYSQL_HOST=mariadb
ENV TS_DB_MYSQL_PORT=3306
ENV TS_DB_MYSQL_USERNAME=teamspeak
ENV TS_DB_MYSQL_PASSWORD=
ENV TS_DB_MYSQL_DATABASE=teamspeak
ENV TS_DB_MYSQL_SOCKET=
# Logs
ENV TS_LOG_PATH=logs/
ENV TS_LOG_APPEND=0
ENV TS_LOG_QUERY_COMMANDS=1
# Misc
ENV TS_LICENSE_PATH=/app/config/licensekey.dat
ENV TS_CREATE_DEFAULT_SERVER=1
ENV TS_MACHINE_ID= 

COPY run.sh /app/

RUN mkdir /app/db/ /app/config/ \
    # Install curl
    && apk update \
    && apk add --virtual .image-setup curl tar \
    # Donwload Dockerize
    && curl -L ${DOCKERIZE_SOURCE} | tar xzC  /usr/local/bin \
    # Download Teamspeak binaries
    && curl -L ${TEAMSPEAK_SOURCE} | tar -xjC /app --strip 1 \
    # Create and link empty sqlite database file
    && touch /app/db/ts3server.sqlitedb \
    && ln -s /app/db/ts3server.sqlitedb /app/ts3server.sqlitedb \
    # Prepare working directory
    && mv /app/redist/libmariadb.so.2 /app/ \
    && chmod +x /app/run.sh \
    # Clean up
    && apk del .image-setup \
    && rm -rf /var/cache/apk/*

VOLUME [ "/app/logs", "/app/files", "/app/db", "/app/config" ]

EXPOSE ${TS_NET_PORT_VOICE}/udp \
    ${TS_NET_PORT_FILETRANFER}/tcp \
    ${TS_NET_PORT_SERVERQUERY}/tcp

WORKDIR /app/
ENTRYPOINT ["/app/run.sh"]