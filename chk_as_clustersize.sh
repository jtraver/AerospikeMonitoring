#!/bin/bash
# Nagios Plugin
# Check Cluster Size

usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike cluster size.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -c       Total number of Aerospike XDR nodes
EOF
}
HOSTNAME=
NODES=
while getopts “hH:c:” OPTION
    do
    case $OPTION in
    h)
    usage
    exit 1
    ;;
    H)
    HOSTNAME=$OPTARG
    ;;
    c)
    NODES=$OPTARG
    ;;
    ?)
    usage
    exit 2
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $NODES ]]
    then
    usage
    exit 2
    fi

if [ ! -e /usr/bin/clinfo ] ; then
  echo "clinfo file does not exist. Exiting."
  exit 2
fi


METRIC=`clinfo -h $HOSTNAME -p 3000 -v statistics | tail -n 1 | cut -d";" -f 1 | cut -d"=" -f 2`

if ! [[ "$METRIC" =~ ^[0-9]+$ ]] ; then
  echo "CRITICAL - Aerospike connection error"
  exit 2
fi

# Comparing the result and setting the correct level:
if [[ $METRIC -lt $CRIT ]]; then
    msg="CRITICAL"
    status=2
else if [[ $METRIC -lt $WARN ]]; then
    msg="WARNING"
    status=1
else
    msg="OK"
    status=0
fi
fi

# Printing the results:
    echo "$msg - $HOSTNAME aerospike cluster size=$METRIC | '$HOSTNAME cluster size'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
