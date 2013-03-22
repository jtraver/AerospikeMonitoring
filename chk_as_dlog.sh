#!/bin/bash
# Nagios Plugin
# Check Dlog Space
usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike free dlog space.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -w       Warning threshold
    -c       Critical threshold
EOF
}
HOSTNAME=
PORT=
WARN=
CRIT=
while getopts “hH:w:c:” OPTION
    do
    case $OPTION in
    h)
    usage
    exit 2
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
  echo "clinfo file does not exist."
  exit 2
fi

METRIC=`/usr/bin/clinfo -p 3004 -h $HOSTNAME -v statistics | tail -n 1 | cut -d";" -f 3 | cut -d"=" -f 2 | cut -d"%" -f 1`
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
    echo "$msg - $HOSTNAME aerospike available disk=$METRIC% | '$HOSTNAME available disk'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
