#!/bin/bash
# Nagios Plugin
# Check Cluster Size
usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike stop writes for a given namespace.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
    -w       Warning threshold
    -c       Critical threshold
    -n       Namespace
EOF
}
HOSTNAME=
PORT=
WARN=
CRIT=
NS=
while getopts “hH:p:w:c:n:” OPTION
    do
    case $OPTION in
    h)
    usage
    exit 1
    ;;
    H)
    HOSTNAME=$OPTARG
    ;;
    p)
    PORT=$OPTARG
    ;;
    w)
    WARN=$OPTARG
    ;;
    c)
    CRIT=$OPTARG
    ;;
    n)
    NS=$OPTARG
    ;;
    ?)
    usage
    exit
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $PORT ]] || [[ -z $WARN ]] || [[ -z $CRIT ]] || [[ -z $NS ]]
    then
    usage
    exit 1
    fi
if [ ! -e /usr/bin/clinfo ] ; then
  echo "clinfo file does not exist. Exiting."
  exit 2
fi

METRIC="$(/usr/bin/clinfo -h $HOSTNAME -p $PORT -v "sets/$NS" | tail -n 1 | cut -d: -f 4 | cut -d= -f2)"

# Comparing the result and setting the correct level:
if [[ $METRIC -gt $CRIT ]]; then
    msg="CRITICAL"
    status=2
else if [[ $METRIC -gt $WARN ]]; then
    msg="WARNING"
    status=1
else
    msg="OK"
    status=0
fi
fi

# Printing the results:
    echo "$msg - $HOSTNAME aerospike stop writes=$METRIC | '$HOSTNAME stop writes'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
