# teamspeak-alpine
![](https://images.microbadger.com/badges/image/jlndbe/teamspeak-alpine.svg)
![](https://images.microbadger.com/badges/version/jlndbe/teamspeak-alpine.svg)

A alpine based customizable TeamSpeak 3 server image without much magic.  
This image does **not** run tsdns.

# Example usage
Here's an easy example how you start a new container. Keep in mind that this will not store your data persistently. If you remove the container, everything is gone.
````sh
docker run -d --name teamspeak \
    -p 9987:9987/udp \
    -p 10011:10011/tcp \
    -p 30033:30033/tcp \
    jlndbe/teamspeak-alpine:latest
````
# Administrator token
You can get the administrator token by using the `docker logs` command.
````sh
docker logs teamspeak
````

# Persistence
You can use [docker volumes](https://docs.docker.com/engine/admin/volumes/volumes/) to persist your Teamspeak server's data.

## Files and folders
The image exposes the following mount points.

| Volume       | Description                                                                                         |
| ------------ |-----------------------------------------------------------------------------------------------------|
| /app/config/ | This is where the `license key` belongs.                                                            |
| /app/logs/   | This folder contains all Teamspeak log files.                                                       |
| /app/files/  | Uploaded files will be stored here.                                                                 |
| /app/db/     | If you use the SQLite driver (default), the database file `ts3server.sqlitedb` will be stored here. |

## SQLite
By default, Teamspeak uses the SQLite driver. The database file is stored under `/app/db/ts3server.sqlitedb`.
````sh
docker run -d --name teamspeak \
    -v teamspeak-logs:/app/logs/ \
    -v teamspeak-files:/app/files/ \
    -v teamspeak-db:/app/db/ \
    -p 9987:9987/udp \
    -p 10011:10011/tcp \
    -p 30033:30033/tcp \
    jlndbe/teamspeak-alpine:latest
````

## MariaDB
If you want to use MariaDB, you need to specify the database plugin with `-e TS_DB_PLUGIN=ts3db_mariadb`. Additionally you need to provide the host, port, username, password and the database to use. This can also be archived with environment variables. Here is a full example using the MariaDB driver and named volumes:
````sh
docker run -d --name teamspeak \
    -v teamspeak-logs:/app/logs/ \
    -v teamspeak-files:/app/files/ \
    -p 9987:9987/udp \
    -p 10011:10011/tcp \
    -p 30033:30033/tcp \
    -e TS_DB_PLUGIN=ts3db_mariadb \
    -e TS_DB_MARIADB_HOST=db.host.example \
    -e TS_DB_MARIADB_PORT=3306 \
    -e TS_DB_MARIADB_USERNAME=user \
    -e TS_DB_MARIADB_PASSWORD=pwd \
    -e TS_DB_MARIADB_DATABASE=teamspeak \
    jlndbe/teamspeak-alpine:latest
````
**Hint:** If the default value of a environment variable matches your configuration, it can be omitted.

### Docker Compose
This image contains [jwilder's dockerize](https://github.com/jwilder/dockerize) to make our lives easier.   
Here is a full [docker-compose](https://docs.docker.com/compose/overview/) example.

````yaml
version: '3'
services:
  teamspeak:
    image: jlndbe/teamspeak-alpine:latest
    depends_on: 
      - mariadb
    ports:
      - "9988:9987/udp"
      - "10012:10011/tcp"
      - "30034:30033/tcp"
    volumes:
      - /var/teamspeak/config/:/app/config
      - teamspeak-logs:/app/logs/
      - teamspeak-files:/app/files/
    environment:
      TS_DB_PLUGIN: ts3db_mariadb
      TS_DB_SQL_CREATE_PATH: create_mariadb/
      TS_DB_MARIADB_PASSWORD: mypassword
    entrypoint: dockerize -wait tcp://mariadb:3306 -timeout 20s /app/run.sh
      
  mariadb:
    image: mariadb
    environment: 
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
      MYSQL_DATABASE: teamspeak
      MYSQL_USER: teamspeak
      MYSQL_PASSWORD: mypassword

volumes:
  teamspeak-logs:
  teamspeak-files:
````

# Adding a license key
If you want to use your own license key, the easiest way to do this is to use a host volume. By default, the server will look for the license file in `/app/config/licensekey.dat`. This can be changed by defining `-e TS_LICENSE_PATH=/app/config/myfancylicensekey.dat`. In the following example, `/path/to/your/config/` contains `licensekey.dat`.
````sh
docker run -d --name teamspeak \
    -v /path/to/your/config/:/app/config/ \
    -v teamspeak-logs:/app/logs/ \
    -v teamspeak-files:/app/files/ \
    -v teamspeak-db:/app/db/ \
    -p 9987:9987/udp \
    -p 10011:10011/tcp \
    -p 30033:30033/tcp \
    jlndbe/teamspeak-alpine:latest
````

## Building your own image
Alternatively, you can bake your license into your own image.
````Dockerfile
FROM teamspeak-alpine:latest

COPY /path/to/your/licensekey.dat /app/config/licensekey.dat
````

# Further configuration
The following is based on the [Teamspeak 3 server quick start guide](http://media.teamspeak.com/ts3_literature/TeamSpeak%203%20Server%20Quick%20Start.txt). The descriptions were taken over.

| Environment variable     | Default value              | Description                                                                                                                                                                                                                                                                                         |
| ------------------------ | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TS_NET_IP_VOICE          | 0.0.0.0                    | IP on which the server instance will listen for incoming voice connections.                                                                                                                                                                                                                         |
| TS_NET_PORT_VOICE        | 9987                       | UDP port open for clients to connect to. This port is used by the first virtual server, subsequently started virtual servers will open on increasing port numbers.                                                                                                                                  |
| TS_NET_IP_FILETRANSFER   | 0.0.0.0                    | IP on which the file transfers are bound to. If you specify this parameter, you also need to specify the "filetransfer_port" parameter!                                                                                                                                                             |
| TS_NET_PORT_FILETRANFER  | 30033                      | TCP Port opened for file transfers. If you specify this parameter, you also need to specify the "filetransfer_ip" parameter!                                                                                                                                                                        |
| TS_NET_IP_SERVERQUERY    | 0.0.0.0                    | IP bound for incoming ServerQuery connections. If you specify this parameter, you also need to specify the "query_port" parameter!                                                                                                                                                                  |
| TS_NET_PORT_SERVERQUERY  | 10011                      | TCP Port opened for ServerQuery connections. If you specify this parameter, need to specify the "query_ip" parameter!                                                                                                                                                                               |
| TS_QUERY_IP_WHITELIST    | query_ip_whitelist.txt     | The file containing whitelisted IP addresses for the ServerQuery interface. All hosts listed in this file will be ignored by the ServerQuery flood protection.                                                                                                                                      |
| TS_QUERY_IP_BLACKLIST    | query_ip_blacklist.txt     | The file containing backlisted IP addresses for the ServerQuery interface. All hosts listed in this file are not allowed to connect to the ServerQuery interface.                                                                                                                                   |
| TS_DB_CLEAR_DATABASE     | 0                          | If set to "1", the server database will be cleared before starting up the server. This is mainly used for testing. Usually this parameter should not be specified, so all server settings will be restored when the server process is restarted.                                                    |
| TS_DB_PLUGIN             | ts3db_sqlite               | Name of the database plugin library used by the server instance. For example, if you want to start the server with MariaDB support, simply set this parameter to `ts3db_MariaDB` to use the MariaDB plugin. Do *NOT* specify the "lib" prefix or the file extension of the plugin.                        |
| TS_DB_PLUGIN_PARAMETER   | ts3db_mariadb.ini          | A custom parameter passed to the database plugin library. For example, the MariaDB database plugin supports a parameter to specify the physical path of the plugins configuration file.                                                                                                                |
| TS_DB_SQL_CREATE_PATH    | create_mariadb/            | The physical path where your SQL installation files are located. Note that this path will be added to the value of the "dbsqlpath" parameter.                                                                                                                                                       |
| TS_DB_CONNECTIONS        | 10                         | The number of database connections used by the server. Please note that changing this value can have an affect on your servers performance. Possible values are 2-100.                                                                                                                              |
| TS_DB_CLIENT_KEEP_DAYS   | 90                         | Defines how many days to keep unused client identities. Auto-pruning is triggered on every start and on every new month while the server is running.                                                                                                                                                |
| TS_DB_LOG_KEEP_DAYS      | 90                         | Defines how many days to keep database log entries. Auto-pruning is triggered on every start and on every new month while the server is running.                                                                                                                                                    |
| TS_DB_MARIADB_HOST         | mariadb                    | The hostname or IP addresses of your MariaDB server.                                                                                                                                                                                                                                                   |
| TS_DB_MARIADB_PORT         | 3306                       | The TCP port of your MariaDB server.                                                                                                                                                                                                                                                                  |
| TS_DB_MARIADB_USERNAME     | teamspeak                  | The username used to authenticate with your MariaDB server.                                                                                                                                                                                                                                           |
| TS_DB_MARIADB_PASSWORD     | <empty>                    | The password used to authenticate with your MariaDB server.                                                                                                                                                                                                                                           |
| TS_DB_MARIADB_DATABASE     | teamspeak                  | The name of a database on your MariaDB server. Note that this database must be created before the TeamSpeak 3 Server is started.                                                                                                                                                                      |
| TS_DB_MARIADB_SOCKET       | <empty>                    | The name of the Unix socket file to use, for connections made via a named pipe to a local server.                                                                                                                                                                                                   |
| TS_LOG_PATH              | logs/                      | The physical path where the server will create logfiles.                                                                                                                                                                                                                                            |
| TS_LOG_APPEND            | 0                          | If set to "1", the server will not create a new logfile on every start. Instead, the log output will be appended to the previous logfile. The logfile name will only contain the ID of the virtual server.                                                                                          |
| TS_LOG_QUERY_COMMANDS    | 1                          | If set to "1", the server will log every ServerQuery command executed by clients. This can be useful while trying to diagnose several different issues.                                                                                                                                             |
| TS_LICENSE_PATH          | /app/config/licensekey.dat | The physical path where your license file is located.                                                                                                                                                                                                                                               |
| TS_CREATE_DEFAULT_SERVER | 1                          | Normally one virtual server is created automatically when the TeamSpeak 3 Server process is started. To disable this behavior, set this parameter to "0". In this case you have to start virtual servers manually using the ServerQuery interface.                                                  |
| TS_MACHINE_ID            | <empty>                    | Optional name of this server process to identify a group of servers with the same ID. This can be useful when running multiple TeamSpeak 3 Server instances on the same database. Please note that we strongly recommend that you do NOT run multiple server instances on the same SQLite database. |
