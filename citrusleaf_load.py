#!/usr/bin/python
#
# A short utility program which pings a given host and requests the 'info' about
# either all names or a certain name
#
#

import sys
import time
import types
import getopt

try:
	import citrusleaf
except:
	print "citrusleaf.py not in your python path. Set PYTHONPATH!"
	sys.exit(-1)	
	
def usage():
	print "Usage:"
	print " -h host (default 127.0.0.1)"
	print " -p port (default 3000)"
	print " -v value (fetch single value - default all)"
	return

#arg processing
try:
	opts, args = getopt.getopt(sys.argv[1:], "h:p:v:", ["host=","port=","value="])
except getopt.GetoptError, err:
	print str(err)
	usage()
	sys.exit(-1)
arg_host = "127.0.0.1"
arg_port = 3000
arg_value = "statistics"
for o, a in opts:
	if ((o == "-h") or (o == "--host")):
		arg_host = a
	if (o == "-p" or o == "--port"):
		arg_port = int(a)

#
# MAINLINE
#

from time import time
new_time=time()

# Nagios error codes:
# STATE_OK=0
# STATE_WARNING=1
# STATE_CRITICAL=2
# STATE_UNKNOWN=3
# STATE_DEPENDENT=4

r = citrusleaf.citrusleaf_info(arg_host, arg_port, arg_value)
if r == -1:
	print "request to ",arg_host,":",arg_port," returned error"
	# return STATE_CRITICAL
	sys.exit(2)
	
if r == None:
	print "request to ",arg_host,":",arg_port," returned no data"
	# return STATE_UNKNOWN
	sys.exit(3)

for s in r.split(";"):
   if "stat_read_success=" in s:
      num_read = s.split("stat_read_success=")[-1]
   if "stat_read_errs_notfound=" in s:
      num_read_fail = s.split("stat_read_errs_notfound=")[-1]
   if "stat_write_success=" in s:
      num_write = s.split("stat_write_success=")[-1]

num_total_read = int(num_read) + int(num_read_fail)

stat_line = repr(new_time) +  " " + repr(num_total_read) + " " + repr(int(num_write)) + "\n"

try:
	f = open('/tmp/stat_file', 'r')
except Exception:
	f = open('/tmp/stat_file', 'w')
	f.write(stat_line);
	f.close
	sys.exit()

old_stat = f.readline()
f.close
stat1=old_stat.split(" ") 
stat2=stat_line.split(" ")

old_time=float(stat1[0])
new_time=float(stat2[0])

old_read=int(stat1[1])
new_read=int(stat2[1])

old_write=int(stat1[2])
new_write=int(stat2[2])

if ((old_time<new_time) and (old_read<=new_read) and (old_write<=new_write)):
	time_taken=new_time - old_time
	read_load=(new_read - old_read)/time_taken
	write_load=(new_write - old_write)/time_taken
	print 'OK - Time Taken: %f, Read Load: %f, Write Load: %f' %(time_taken,read_load,write_load)

f = open('/tmp/stat_file', 'w')
f.write(stat_line);
f.close
