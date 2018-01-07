#!/bin/sh
args="default_voice_port=$TS_NET_PORT_VOICE \
    voice_ip=$TS_NET_IP_VOICE \
    filetransfer_port=$TS_NET_PORT_FILETRANFER \
    filetransfer_ip=$TS_NET_IP_FILETRANSFER \
    query_port=$TS_NET_PORT_SERVERQUERY \
    query_ip=$TS_NET_IP_SERVERQUERY \
    licensepath=$TS_LICENSE_PATH \
    create_default_virtualserver=$TS_CREATE_DEFAULT_SERVER \
    machine_id=$TS_MACHINE_ID \
    clear_database=$TS_DB_CLEAR_DATABASE \
    dbplugin=$TS_DB_PLUGIN \
    dbpluginparameter=$TS_DB_PLUGIN_PARAMETER \
    dbsqlcreatepath=$TS_DB_SQL_CREATE_PATH \
    dbclientkeepdays=$TS_DB_CLIENT_KEEP_DAYS \
    dblogkeepdays=$TS_DB_LOG_KEEP_DAYS \
    dbconnections=$TS_DB_CONNECTIONS \
    query_ip_whitelist=$TS_QUERY_IP_WHITELIST \
    query_ip_backlist=$TS_QUERY_IP_BLACKLIST \
    logpath=$TS_LOG_PATH \
    logappend=$TS_LOG_APPEND \
    logquerycommands=$TS_LOG_QUERY_COMMANDS"

configFile="/app/$TS_DB_PLUGIN_PARAMETER"
touch $configFile

echo [config] >> $configFile
echo host=$TS_DB_MYSQL_HOST >> $configFile
echo port=$TS_DB_MYSQL_PORT >> $configFile
echo username=$TS_DB_MYSQL_USERNAME >> $configFile
echo password=$TS_DB_MYSQL_PASSWORD >> $configFile
echo database=$TS_DB_MYSQL_DATABASE >> $configFile
echo socket=$TS_DB_MYSQL_SOCKET >> $configFile

echo "args:$args"
./ts3server_minimal_runscript.sh $args
