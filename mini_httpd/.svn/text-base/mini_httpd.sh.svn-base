#!/bin/sh
#
# mini_httpd.sh - startup script for mini_httpd on FreeBSD
#
# This goes in /usr/local/etc/rc.d and gets run at boot-time.

case "$1" in
 
    start)
	/mnt/disk/bin/mini_httpd -p 80 -u root -d /mnt/disk/webbox/www -c cgi/* -i /var/run/mini_httpd.pid
    ;;

    stop)
    kill -USR1 `cat /var/run/mini_httpd.pid`
    ;;
	    
    *)
    echo "usage: $0 { start | stop }" >&2
    exit 1
    ;;
			     
esac



