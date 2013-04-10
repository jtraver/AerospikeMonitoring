#!/bin/bash
# Nagios Plugin
# Checks for stopwrites
usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike stop writes.
This script creates a temporary file at /tmp/.aerospike-stat_evicted_objects
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
EOF
}
HOSTNAME=
PORT=
PLUGINDIR=
OUT=
while getopts “hH:p:” OPTION
    do
    case $OPTION in
    h)
    usage
    exit 2
    ;;
    H)
    HOSTNAME=$OPTARG
    ;;
    p)
    PORT=$OPTARG
    ;;
    ?)
    usage
    exit 2
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $PORT ]]
    then
    usage
    exit 2
    fi
if [ ! -e /usr/bin/clinfo ] ; then
  echo "clinfo file does not exist. Exiting."
  exit 2
fi

NS=`/usr/bin/clinfo -v namespaces -h $HOSTNAME | tail -n 1 | cut -d" " -f 4 | tr ";" " "`
msg="OK"

for i in $NS; do
  output=`/usr/bin/clinfo -v namespace/$i -h $HOSTNAME | grep -o "stop-writes=[a-z]*" | cut -d"=" -f2`

  if [[ ! $output == "true" ]] && [[ ! $output == "false" ]]; then
    echo "CRITICAL - Aerospike connection error"
    exit 2
  fi 
  if [ $output == "true" ]; then
    msg="CRITICAL"
  fi
done

# Printing the results:
if [[ $msg == "OK" ]] ; then
  echo "$msg - $HOSTNAME aerospike stopwrites=false | '$HOSTNAME stopwrites'=false;true;true;"
  exit 0
elif [[ $msg == "CRITICAL" ]] ; then
  echo "$msg - $HOSTNAME aerospike stopwrites=true | '$HOSTNAME stopwrites'=true;true;true;"
  exit 2
fi
