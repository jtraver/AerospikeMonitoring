#!/bin/bash
# Nagios Plugin
# Check Cluster Size
if [ ! -e citrusleaf_stats.py ] ; then

  echo "citrusleaf_stats.py file does not exist."
  exit 2
fi

usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for namespace objects.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
    -w       Warning threshold
    -c       Critical threshold
    -n       Namespace or namespace map
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
  echo "clmonitor file does not exist. Exiting."
  exit 2
fi

METRIC="$(clinfo -h $HOSTNAME -p $PORT -v $NS| tail -n 1 | cut -d';' -f 2)"

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
    echo "$msg - $HOSTNAME aerospike namespace $NS objects=$METRIC | '$HOSTNAME aerospike $NS  objs'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
