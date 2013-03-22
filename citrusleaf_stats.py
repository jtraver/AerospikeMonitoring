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
	print " -s \"statistics variable list\" (Eg: \"read_stats uptime write_stats\")"
	return

#arg processing
try:
	opts, args = getopt.getopt(sys.argv[1:], "h:p:s:", ["host=","port=","statistics="])
except getopt.GetoptError, err:
	print str(err)
	usage()
	sys.exit(-1)
arg_host = "127.0.0.1"
arg_port = 3000
arg_value = "statistics"
arg_stat = "write_stats"
for o, a in opts:
	if ((o == "-h") or (o == "--host")):
		arg_host = a
	if (o == "-p" or o == "--port"):
		arg_port = int(a)
	if (o == "-s" or o == "--statistics"):
		arg_stat = a

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

stat_line = ""

for arg in arg_stat.split():
	this_stat_line=""
	if arg == "write_stats":
		for s in r.split(";"):
		   if "stat_write_success=" in s:
		      num_write = s.split("stat_write_success=")[-1]

		stat_line_w = repr(new_time) +  " " + repr(int(num_write)) + "\n"

		try:
			f = open('/tmp/stat_file_w', 'r')
		except Exception:
			f = open('/tmp/stat_file_w', 'w')
			f.write(stat_line_w);
			f.close
			continue

		old_stat = f.readline()
		if (old_stat == None):
			print "Wrong stat file. Please delete /tmp/stat_file_w"
			f.close
			sys.exit()

		f.close
		stat1=old_stat.split(" ") 
		stat2=stat_line_w.split(" ")

		old_time=float(stat1[0])
		new_time=float(stat2[0])

		old_write=int(stat1[1])
		new_write=int(stat2[1])

		if ((old_time<new_time) and (old_write<=new_write)):
			time_taken=new_time - old_time
			write_load=(new_write - old_write)/time_taken
			this_stat_line = 'Write_Load=' + repr(write_load)


		f = open('/tmp/stat_file_w', 'w')
		f.write(stat_line_w);
		f.close

	elif arg == "read_stats":
		for s in r.split(";"):
		   if "stat_read_success=" in s:
		      num_read = s.split("stat_read_success=")[-1]
		   if "stat_read_errs_notfound=" in s:
		      num_read_fail = s.split("stat_read_errs_notfound=")[-1]

		num_total_read = int(num_read) + int(num_read_fail)
		stat_line_r = repr(new_time) +  " " + repr(num_total_read) + "\n"

		try:
			f = open('/tmp/stat_file_r', 'r')
		except Exception:
			f = open('/tmp/stat_file_r', 'w')
			f.write(stat_line_r);
			f.close
			continue

		old_stat = f.readline()
		f.close
		stat1=old_stat.split(" ")
		stat2=stat_line_r.split(" ")

		old_time=float(stat1[0])
		new_time=float(stat2[0])

		old_read=int(stat1[1])
		new_read=int(stat2[1])

		if ((old_time<new_time) and (old_read<=new_read)):
			time_taken=new_time - old_time
			read_load=(new_read - old_read)/time_taken
			this_stat_line = 'Read_Load=' + repr(read_load)

		f = open('/tmp/stat_file_r', 'w')
		f.write(stat_line_r);
		f.close

	else:
		num_stat = None
		for s in r.split(";"):
		   if arg + "=" in s:
		      num_stat = s.split(arg + "=")[-1]
		if num_stat != None:
			this_stat_line = arg + "=" + num_stat

	if this_stat_line != "":
		if stat_line == "":
			stat_line='Citrusleaf Stats - ' + this_stat_line
		else:
			stat_line=stat_line + ' ' + this_stat_line
		
if stat_line != "":
	print '%s' %(stat_line)
