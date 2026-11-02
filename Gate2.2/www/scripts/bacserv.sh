#!/bin/sh
#
# copy file to /etc/init.d
# update-rc.d bacserv.sh defaults 99

case "$1" in
 
    start)
	/mnt/disk/webbox/bacnet/bacserv -i /var/run/bacserv.pid
    ;;

    stop)
    kill -USR1 `cat /var/run/bacserv.pid`
    ;;
	    
    *)
    echo "usage: $0 { start | stop }" >&2
    exit 1
    ;;
			     
esac



