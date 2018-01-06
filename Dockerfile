FROM frolvlad/alpine-glibc:latest
LABEL MAINTAINER='Johlandabee <contact@jlndbe.me>' \
      teamspeak.server.version=3.0.13.8

ENV SOURCE=http://dl.4players.de/ts/releases/3.0.13.8/teamspeak3-server_linux_amd64-3.0.13.8.tar.bz2 \
    # Network
    TS_NET_IP_VOICE=0.0.0.0 \
    TS_NET_PORT_VOICE=9987 \
    TS_NET_IP_FILETRANSFER=0.0.0.0 \
    TS_NET_PORT_FILETRANFER=30033 \
    TS_NET_IP_SERVERQUERY=0.0.0.0 \
    TS_NET_PORT_SERVERQUERY=10011 \
    # Query white/blacklist
    TS_QUERY_IP_WHITELIST=query_ip_whitelist.txt \
    TS_QUERY_IP_BLACKLIST=query_ip_whitelist.txt \
    # Database
    TS_DB_CLEAR_DATABASE=0 \
    TS_DB_PLUGIN=ts3db_sqlite3 \
    TS_DB_CONNECTIONS=10 \
    TS_DB_CLIENT_KEEP_DAYS=90 \
    TS_DB_LOG_KEEP_DAYS=90 \
    TS_DB_MYSQL_HOST=mysql \
    TS_DB_MYSQL_PORT=3306 \
    TS_DB_MYSQL_USERNAME=root \
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
    
    # Create directories
RUN mkdir /app/ /app/db/ /app/config/ \
    # Install curl
    && apk update \
    && apk add --virtual .image-setup curl \
    # Download Teamspeak binaries
    && curl ${SOURCE} | tar -xjC /app --strip 1 \
    # Create and link empty sqlite database file
    && touch /app/db/ts3server.sqlitedb \
    && ln -s /app/db/ts3server.sqlitedb /app/ts3server.sqlitedb \
    # Create MySQL config file
    && touch /app/config/ts3db_mysql.ini \
    # Write MySQL configuraiton from env vars
    && echo [config] >> /app/config/ts3db_mysql.ini \
    && echo host=${TS_DB_MYSQL_HOST} >> /app/config/ts3db_mysql.ini \
    && echo port=${TS_DB_MYSQL_PORT} >> /app/config/ts3db_mysql.ini \
    && echo username=${TS_DB_MYSQL_USERNAME} >> /app/config/ts3db_mysql.ini \
    && echo password=${TS_DB_MYSQL_PASSWORD} >> /app/config/ts3db_mysql.ini \
    && echo database=${TS_DB_MYSQL_DATABASE} >> /app/config/ts3db_mysql.ini \
    && echo socket=${TS_DB_MYSQL_SOCKET} >> /app/config/ts3db_mysql.ini \
    # Link MySQL config file
    && ln -s /app/config/ts3db_mysql.ini /app/ts3db_mysql.ini \
    # Clean up
    && apk del .image-setup \
    && rm -rf /var/cache/apk/* 

VOLUME [ "/app/logs", "/app/files", "/app/db", "/app/config" ]

EXPOSE ${TS_NET_PORT_VOICE}/udp \
       ${TS_NET_PORT_FILETRANFER}/tcp \
       ${TS_NET_PORT_SERVERQUERY}/tcp

WORKDIR /app/
ENTRYPOINT [ "/bin/sh", "/app/ts3server_minimal_runscript.sh" ]
CMD [ "default_voice_port=${TS_NET_PORT_VOICE}", \
      "voice_ip=${TS_NET_IP_VOICE}", \
      "filetransfer_port=${TS_NET_PORT_FILETRANFER}", \
      "filetransfer_ip=${TS_NET_IP_FILETRANSFER}", \
      "query_port=${TS_NET_PORT_SERVERQUERY}", \
      "query_ip=${TS_NET_IP_SERVERQUERY}", \
      "licensepath=${TS_LICENSE_PATH}", \
      "create_default_virtualserver=${TS_CREATE_DEFAULT_SERVER}", \
      "machine_id=${TS_MACHINE_ID}", \
      "clear_database=${TS_DB_CLEAR_DATABASE}", \
      "dbplugin=${TS_DB_PLUGIN}", \
      "query_ip_whitelist=${TS_QUERY_IP_WHITELIST}", \
      "query_ip_backlist=${TS_QUERY_IP_BLACKLIST}", \
      "dbclientkeepdays=${TS_DB_CLIENT_KEEP_DAYS}", \
      "dblogkeepdays=${TS_DB_LOG_KEEP_DAYS}", \
      "dbconnections=${TS_DB_CONNECTIONS}", \
      "logpath=${TS_LOG_PATH}", \
      "logappend=${TS_LOG_APPEND}", \
      "logquerycommands=${TS_LOG_QUERY_COMMANDS}" \]