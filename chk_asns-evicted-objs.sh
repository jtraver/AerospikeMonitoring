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
This nagios plugins checks for evicted objects.
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

 #clmonitor -e "info XDR" -h sjc-aero1.alcfd.com | tail -n 4 | head -n 3 | awk '{ print $6 }' | tr , "\n" > /tmp/.aerospike_lag_check
#echo Running clmonitor, $HOSTNAME:$PORT
METRIC="$(clinfo -h $HOSTNAME -p $PORT -v $NS| tail -n 1 | cut -d';' -f 4)"

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
    echo "$msg - $HOSTNAME aerospike namespace $NS evicted-objects=$METRIC | '$HOSTNAME aerospike $NS evicted-objs'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
