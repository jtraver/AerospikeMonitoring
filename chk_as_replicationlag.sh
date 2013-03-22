#!/bin/bash
# Nagios Plugin
# Check Replication Lag

usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike XDR replication lag.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -w       Warning threshold
    -c       Critical threshold
EOF
}
HOSTNAME=
WARN=
CRIT=
while getopts “hH:c:w:” OPTION
    do
    case $OPTION in
    h)
    usage
    exit 1
    ;;
    H)
    HOSTNAME=$OPTARG
    ;;
    w)
    WARN=$OPTARG
    ;;
    c)
    CRIT=$OPTARG
    ;;
    ?)
    usage
    exit 2
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $WARN ]] || [[ -z $CRIT ]]
    then
    usage
    exit 2
    fi

if [ ! -e /usr/bin/clinfo ] ; then
  echo "clinfo file does not exist. Exiting."
  exit 2
fi

METRIC=`/usr/bin/clinfo -h $HOSTNAME -p 3004 -v statistics | tail -n 1 | cut -d";" -f 27 | cut -d"=" -f 2| tr "," " "`


for i in $METRIC; do
if ! [[ "$i" =~ ^[0-9]+$ ]] ; then
  echo "CRITICAL - Aerospike connection error"
  exit 2
fi

if [[ $i -gt $CRIT ]]; then
    msg="CRITICAL"
    status=2
    break
else if [[ $i -gt $WARN ]]; then
    msg="WARNING"
    status=1
else
    msg="OK"
    status=0
fi
fi

done

# Printing the results:
	echo "$msg - $HOSTNAME aerospike replication lag=$METRICs | '$HOSTNAME as replication lag'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
