#!/bin/bash

# we should get env ${CATALINA_HOME} from upstream container docker
set -e

JAVA_XMS=${JAVA_XMS:-'2048M'}
JAVA_XMX=${JAVA_XMX:-'2048M'}
DEBUG=${DEBUG:-'false'}
JMX_ENABLED=${JMX_ENABLED:-'false'}
JMX_RMI_HOST=${JMX_RMI_HOST:-'0.0.0.0'}

TOMCAT_ROOT=${CATALINA_HOME}
CONFIG_FILE=${TOMCAT_ROOT}'/shared/classes/alfresco-global.properties'
TOMCAT_CONFIG_FILE=${TOMCAT_ROOT}'/bin/setenv.sh'
TOMCAT_SERVER_FILE=${TOMCAT_ROOT}'/conf/server.xml'
TOMCAT_CONTEXT_FILE=${TOMCAT_ROOT}'/conf/context.xml'

SOLR_SSL=${SOLR_SSL:-'https'}

# sets an Alfresco parameter in alfresco-global.properties
function setGlobalOption {
    if grep --quiet -e "$1\s*=" "$CONFIG_FILE"; then
        # replace option
        sed -i "s#^\($1\s*=\s*\).*\$#\1$2#" $CONFIG_FILE
        if (( $? )); then
            echo "setGlobalOption failed (replacing option $1=$2 in $CONFIG_FILE)"
            exit 1
        fi
    else
        # add option if it does not exist
        echo "$1=$2" >> $CONFIG_FILE
    fi
}

# sets an Alfresco / Tomcat parameter as a JAVA_OPTS parameter
# the key is ignored, the value should contain the "-D" flag if it's a property
function setJavaOption {
    JAVA_OPTS="$JAVA_OPTS $2"
}

function setGlobalOptions {
    IFS=$'\n'
    for i in `env`
    do
	if [[ $i == GLOBAL_* ]]
	    then
	    key=`echo $i | cut -d '=' -f 1 | cut -d '_' -f 2-`
	    value=`echo $i | cut -d '=' -f 2-`
	    setGlobalOption $key $value
	fi
    done
}

function setJavaOptions {
    IFS=$'\n'
    for i in `env`
    do
	if [[ $i == JAVA_OPTS_* ]]
	    then
	    key=`echo $i | cut -d '=' -f 1 | cut -d '_' -f 3-`
	    value=`echo $i | cut -d '=' -f 2-`
	    setJavaOption $key $value
	fi
    done
}

setGlobalOption 'alfresco.host' "${ALFRESCO_HOST:-localhost}"
setGlobalOption 'alfresco.port' "${ALFRESCO_PORT:-8080}"
setGlobalOption 'alfresco.protocol' "${ALFRESCO_PROTOCOL:-http}"

setGlobalOption 'share.host' "${SHARE_HOST:-localhost}"
setGlobalOption 'share.port' "${SHARE_PORT:-8080}"
setGlobalOption 'share.protocol' "${SHARE_PROTOCOL:-http}"

setGlobalOption 'db.driver' "${DB_DRIVER:-org.postgresql.Driver}"
setGlobalOption 'db.host' "${DB_HOST:-localhost}"
setGlobalOption 'db.port' "${DB_PORT:-5432}"
setGlobalOption 'db.name' "${DB_NAME:-alfresco}"
setGlobalOption 'db.username' "${DB_USERNAME:-alfresco}"
setGlobalOption 'db.password' "${DB_PASSWORD:-admin}"
setGlobalOption 'db.url' "${DB_URL:-jdbc:postgresql://postgresql:5432/alfresco}"
setGlobalOption 'db.pool.validate.query' "${DB_QUERY:-select 1}"

# Search
if [[ $ALFRESCO_VERSION = "4"* ]]  # version 4 uses the bundled Alfresco with solr
then
    setGlobalOption 'index.subsystem.name' "${INDEX:-solr}"
elif [[ $ALFRESCO_VERSION = "5.0"* ]] || [[ $ALFRESCO_VERSION = "5.1"* ]]
then
    setGlobalOption 'index.subsystem.name' "${INDEX:-solr4}"
elif [[ $ALFRESCO_VERSION = "5.2"* ]]
then
    setGlobalOption 'index.subsystem.name' "${INDEX:-solr6}"
else
    setGlobalOption 'index.subsystem.name' "${INDEX:-solr6}"
fi

setGlobalOption 'solr.host' "${SOLR_HOST:-solr}"
setGlobalOption 'solr.port' "${SOLR_PORT:-8080}"
setGlobalOption 'solr.port.ssl' "${SOLR_PORT_SSL:-8443}"
setGlobalOption 'solr.useDynamicShardRegistration' "${DYNAMIC_SHARD_REGISTRATION:-false}"
setGlobalOption 'solr.secureComms' "${SOLR_SSL:-https}"
if [[ $SOLR_SSL = none ]] && [[ $ALFRESCO_VERSION != "5.0"* ]] && [[ $ALFRESCO_VERSION != "3"* ]] && [[ $ALFRESCO_VERSION != "4"* ]]
then
#remove the SSL connector
sed -i '/<Connector port="\${TOMCAT_PORT_SSL}" URIEncoding="UTF-8" protocol="org.apache.coyote.http11.Http11Protocol" SSLEnabled="true"/,+5d' $TOMCAT_SERVER_FILE
fi

# System
setGlobalOption 'mail.host' "${MAIL_HOST:-localhost}"
setGlobalOption 'cifs.enabled' "${ENABLE_CIFS:-false}" # CIFS Configuration
setGlobalOption 'ftp.enabled' "${ENABLE_FTP:-false}" # CIFS Configuration
setGlobalOption 'alfresco.cluster.enabled' "${ENABLE_CLUSTERING:-false}" # Cluster Configuration

# Tomcat-related properties
# for backwards compatibility, we keep the old options as well
setJavaOption 'TOMCAT_PORT' '-DTOMCAT_PORT='${TOMCAT_PORT:-8080}
setJavaOption 'TOMCAT_PORT_SSL' '-DTOMCAT_PORT_SSL='${TOMCAT_PORT_SSL:-8443}
setJavaOption 'TOMCAT_AJP_PORT' '-DTOMCAT_AJP_PORT='${TOMCAT_AJP_PORT:-8009}
setJavaOption 'TOMCAT_SERVER_PORT' '-DTOMCAT_SERVER_PORT='${TOMCAT_SERVER_PORT:-8005}
BC_TOMCAT_MAX_HTTP_HEADER_SIZE=${TOMCAT_MAX_HTTP_HEADER_SIZE:-$MAX_HTTP_HEADER_SIZE}
setJavaOption 'TOMCAT_MAX_HTTP_HEADER_SIZE' '-DTOMCAT_MAX_HTTP_HEADER_SIZE='${BC_TOMCAT_MAX_HTTP_HEADER_SIZE:-32768}
BC_TOMCAT_MAX_THREADS=${TOMCAT_MAX_THREADS:-$MAX_THREADS}
setJavaOption 'TOMCAT_MAX_THREADS' '-DTOMCAT_MAX_THREADS='${BC_TOMCAT_MAX_THREADS:-200}

if [ $JMX_ENABLED = true ]
then
    JAVA_OPTS="$JAVA_OPTS -Xms$JAVA_XMS -Xmx$JAVA_XMX -Dfile.encoding=UTF-8 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.rmi.port=5000 -Dcom.sun.management.jmxremote.port=5000 -Djava.rmi.server.hostname=$JMX_RMI_HOST"
    setGlobalOption 'alfresco.jmx.connector.enabled' 'true'
else
    JAVA_OPTS="$JAVA_OPTS -Xms$JAVA_XMS -Xmx$JAVA_XMX -Dfile.encoding=UTF-8"
fi

if [ $DEBUG = true ]
then
    JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
fi

sed -i "s|\(<Context>\)|\1\n<Manager pathname=\"\" />|" ${TOMCAT_CONTEXT_FILE} || exit 1 # No persistent sessions after restart

setGlobalOptions
setJavaOptions

echo "JAVA_OPTS=\""\$JAVA_OPTS" $JAVA_OPTS\"" >$TOMCAT_CONFIG_FILE
echo "export JAVA_OPTS" >> $TOMCAT_CONFIG_FILE

appStart () {
    if [[ $ALFRESCO_FLAVOR == enterprise-bundle ]]
    then
	user="alfresco"
    else
	user="tomcat"
    fi
    if [[ $(stat -c %U /opt/alfresco/alf_data) != "$user" ]]
    then
	chown -R $user:$user /opt/alfresco/alf_data
    fi
    if [[ $(stat -c %U "$CATALINA_HOME/temp") != "$user" ]]
    then
	chown -R $user:$user "$CATALINA_HOME"/temp
    fi
    if [[ $ALFRESCO_FLAVOR == enterprise-bundle ]]
    then
	gosu "$user" /opt/alfresco/alfresco.sh start
	tail -f /opt/alfresco/tomcat/logs/catalina.out
    else
	gosu "$user" ${CATALINA_HOME}/bin/catalina.sh run
    fi
}

appHelp () {
  echo "Available options:"
  echo " app:start    - Start the application"
  echo " app:help     - Displays the help"
  echo " [command]    - Execute the specified linux command eg. bash."
}


case "$1" in
  app:start)
    appStart
    ;;
  app:help)
    appHelp
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "${prog}" ] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
