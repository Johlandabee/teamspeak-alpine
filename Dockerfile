FROM frolvlad/alpine-glibc:latest
LABEL MAINTAINER='Johlandabee <contact@jlndbe.me>' \
    teamspeak.server.version=3.0.13.8

ENV DOCKERIZE_SOURCE=https://github.com/jwilder/dockerize/releases/download/v0.6.0/dockerize-alpine-linux-amd64-v0.6.0.tar.gz \
    SOURCE=http://dl.4players.de/ts/releases/3.0.13.8/teamspeak3-server_linux_amd64-3.0.13.8.tar.bz2 \
    # Network
    TS_NET_IP_VOICE=0.0.0.0 \
    TS_NET_PORT_VOICE=9987 \
    TS_NET_IP_FILETRANSFER=0.0.0.0 \
    TS_NET_PORT_FILETRANFER=30033 \
    TS_NET_IP_SERVERQUERY=0.0.0.0 \
    TS_NET_PORT_SERVERQUERY=10011 \
    # Query white/blacklist
    TS_QUERY_IP_WHITELIST=query_ip_whitelist.txt \
    TS_QUERY_IP_BLACKLIST=query_ip_blacklist.txt \
    # Database
    TS_DB_CLEAR_DATABASE=0 \
    TS_DB_PLUGIN=ts3db_sqlite3 \
    TS_DB_PLUGIN_PARAMETER=ts3db_mariadb.ini \
    TS_DB_CONNECTIONS=10 \
    TS_DB_CLIENT_KEEP_DAYS=90 \
    TS_DB_LOG_KEEP_DAYS=90 \
    TS_DB_SQL_CREATE_PATH=create_mariadb/ \
    TS_DB_MYSQL_HOST=mariadb \
    TS_DB_MYSQL_PORT=3306 \
    TS_DB_MYSQL_USERNAME=teamspeak \
    TS_DB_MYSQL_PASSWORD= \
    TS_DB_MYSQL_DATABASE=teamspeak \
    TS_DB_MYSQL_SOCKET= \
    # Logs
    TS_LOG_PATH=logs/ \
    TS_LOG_APPEND=0 \
    TS_LOG_QUERY_COMMANDS=1 \
    # Misc
    TS_LICENSE_PATH=/app/config/licensekey.dat \
    TS_CREATE_DEFAULT_SERVER=1 \
    TS_MACHINE_ID= 

COPY run.sh /app/

# Create directories
RUN mkdir /app/db/ /app/config/ \
    # Install curl
    && apk update \
    && apk add --virtual .image-setup curl tar \
    # Donwload Dockerize
    && curl -L ${DOCKERIZE_SOURCE} | tar xzC  /usr/local/bin \
    # Download Teamspeak binaries
    && curl ${SOURCE} | tar -xjC /app --strip 1 \
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