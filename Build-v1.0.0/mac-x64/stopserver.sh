#!/bin/bash

PROPERTIESFILENAME="./config/application.properties"
serverport=0
httpport=0

processPropertiesPort()
{
    # Process the properties file: $PROPERTIESFILENAME
    if [ -f $PROPERTIESFILENAME ]; then
        serverport=$(cat $PROPERTIESFILENAME 2>/dev/null | grep '^server.port=' | sed -e 's/server.port=//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
        httpport=$(cat $PROPERTIESFILENAME 2>/dev/null | grep '^server.http-port=' | sed -e 's/server.http-port=//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' )
    fi
    return 0
}

closePortByPortId()
{
    srcport=$1
    # Close port in use
    if [[ $(lsof -i tcp:$srcport 2>/dev/null | awk -v portNum=":$srcport" '$0 ~ portNum {print $2}' | xargs -I {} sh -c 'kill {} 2>/dev/null || kill -9 {}  2>/dev/null') \
            || $(fuser -k $srcport/tcp 2>/dev/null ) \
            || $(ss -ltpH "sport = :$srcport" 2>/dev/null | sed -e 's/.*pid=//' | sed -e 's/,.*$//' | xargs -I {} sh -c 'kill {} 2>/dev/null || kill -9 {} 2>/dev/null' ) \
        ]] ; then 
       return 0
    else
       return 1
    fi
}
stopTheServerApp()
{
    # Stop the server application
    if [[ $serverport > 0 ]]; then
        closePortByPortId $serverport
    fi
    if [[ $httpport > 0 ]] ; then
        closePortByPortId $httpport
    fi
}

processPropertiesPort
stopTheServerApp

