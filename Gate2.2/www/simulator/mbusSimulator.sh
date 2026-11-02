#!/bin/sh
#
# MbusSimulator.sh - startup script for MbusSimulator on FreeBSD
#
# This goes in /usr/local/etc/rc.d and gets run at boot-time.

case "$1" in
 
    start)
	/mnt/disk/webbox/simulator/MbusSimulator -u root -i /var/run/MbusSimulator.pid
	/mnt/disk/webbox/bacnet/bacserv -i /var/run/bacserv.pid
    ;;

    stop)
    kill -USR1 `cat /var/run/MbusSimulator.pid`
    kill -USR1 `cat /var/run/bacserv.pid`
    ;;
	    
    *)
    echo "usage: $0 { start | stop }" >&2
    exit 1
    ;;
			     
esac



