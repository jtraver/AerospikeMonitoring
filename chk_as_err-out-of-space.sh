#!/bin/bash
# Nagios Plugin
# Check Cluster Size
usage()
{
cat << EOF
usage: $0 options
By AppLovin Ops Team. www.applovin.com.
This nagios plugins checks for aerospike err_out_of_space. The same number over a 1 minute period may indicate a problem.
This script creates a temporary file at /tmp/.aerospike-err_out_of_space
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
    -n       Nagios plugins dir ($USER1$)
EOF
}
HOSTNAME=
PORT=
WARN=
CRIT=
PLUGINDIR=
while getopts “hH:p:n:” OPTION
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
    n)
    PLUGINDIR=$OPTARG
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
if [ ! -e $PLUGINDIR/citrusleaf_stats.py ] ; then
  echo "citrusleaf_stats.py file does not exist."
  exit 2
fi
if [ ! -e /usr/bin/clmonitor ] ; then
  echo "clmonitor file does not exist. Exiting."
  exit 2
fi

METRIC="$(python $PLUGINDIR/citrusleaf_stats.py -h $HOSTNAME -p $PORT -s err_out_of_space | cut -d= -f 2)"

if ! [[ "$METRIC" =~ ^[0-9]+$ ]] ; then
  echo "CRITICAL - Aerospike connection error"
  exit 2
fi

if [[ $METRIC -eq 0 ]]; then
    msg="OK"
    status=0
else if [[ $METRIC -ne 0 ]]; then
    msg="CRITICAL"
    status=2
fi
fi
# Printing the results:
echo "$msg - $HOSTNAME aerospike err_out_of_space=$METRIC | '$HOSTNAME err_out_of_space'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
