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
This nagios plugins checks for aerospike stat_read_reqs. The same number over a 1 minute period may indicate a problem.
This script creates a temporary file at /tmp/.aerospike-stat_read_reqs
OPTIONS:
    -h       Show this message
    -H       Hostname
    -p       Server port
EOF
}
HOSTNAME=
PORT=
WARN=
CRIT=
while getopts “hH:p:” OPTION
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
    ?)
    usage
    exit
    ;;
    esac
    done
    if [[ -z $HOSTNAME ]] || [[ -z $PORT ]]
    then
    usage
    exit 1
    fi
if [ ! -e /usr/bin/clmonitor ] ; then
  echo "clmonitor file does not exist. Exiting."
  exit 2
fi

 #clmonitor -e "info XDR" -h sjc-aero1.alcfd.com | tail -n 4 | head -n 3 | awk '{ print $6 }' | tr , "\n" > /tmp/.aerospike_lag_check
#echo Running clmonitor, $HOSTNAME:$PORT
METRIC="$(python citrusleaf_stats.py -h $HOSTNAME -p $PORT -s stat_read_reqs | cut -d= -f 2)"

#if [ -z $METRIC ] ; then
#  echo -e "CRITICAL - cannot obtain replication latencies | Error on $HOSTNAME:$PORT aerospike lag check"
#  exit 2
#fi



# Comparing the result and setting the correct level:

if [ -e /tmp/.aerospike-stat_read_reqs ]; then
# Count size of the file, makes sure it is only 1
    if [ `cat /tmp/.aerospike-stat_read_reqs | wc -l` -eq 1 ]; then
        VAR1=`cat /tmp/.aerospike-stat_read_reqs`
    else
        rm -vfr /tmp/.aerospike-stat_read_reqs
        echo -e "CRITICAL | /tmp/.aerospike-stat_read_reqs read file error"
        exit 2
    fi

fi

if [[ $METRIC -eq $VAR1 ]]; then
    msg="CRITICAL"
    status=2
else if [[ $METRIC -ne $VAR1 ]]; then
    msg="OK"
    status=0
fi
fi

# Printing the results:
echo $METRIC > /tmp/.aerospike-stat_read_reqs

echo "$msg - $HOSTNAME aerospike stat_read_reqs=$METRIC | '$HOSTNAME stat_read_reqs'=$METRIC;$WARN;$CRIT;"

# Bye!
exit $status
