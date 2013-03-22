#!/bin/bash
# Nagios Plugin
# Check Cluster Size
usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike free space.
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
    -w       Warning threshold
    -c       Critical threshold
    -n       Nagios Plugin Dir ($USER1$)
EOF
}
HOSTNAME=
PORT=
WARN=
CRIT=
PLUGINDIR=
while getopts “hH:p:w:c:n:” OPTION
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
    w)
    WARN=$OPTARG
    ;;
    c)
    CRIT=$OPTARG
    ;;
    n)
    PLUGINDIR=$OPTARG
    ;;
    ?)
    usage
    exit 2
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $PORT ]] || [[ -z $WARN ]] || [[ -z $CRIT ]] || [[ -z $PLUGINDIR ]]
    then
    usage
    exit 2
    fi

if [ ! -e $PLUGINDIR/citrusleaf_stats.py ] ; then
  echo "citrusleaf_stats.py file does not exist."
  exit 2
fi

if [ ! -e /usr/bin/clmonitor ] ; then
  echo "clmonitor file does not exist. Exiting."
  exit 2
fi

 #clmonitor -e "info XDR" -h sjc-aero1.alcfd.com | tail -n 4 | head -n 3 | awk '{ print $6 }' | tr , "\n" > /tmp/.aerospike_lag_check
#echo Running clmonitor, $HOSTNAME:$PORT
METRIC="$(python $PLUGINDIR/citrusleaf_stats.py -h $HOSTNAME -p $PORT -s free-pct-disk | cut -d= -f 2)"

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
