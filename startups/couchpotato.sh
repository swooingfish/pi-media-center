#!/bin/sh
### BEGIN INIT INFO
# Provides: CouchPotato
# Required-Start: $network $remote_fs $syslog
# Required-Stop: $network $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start CouchPotato at boot time
# Description: Start CouchPotato.
### END INIT INFO
case "$1" in
start)
 echo "Starting CouchPotato."
 /usr/bin/sudo -u couchpotato -H /usr/local/couchpotato/CouchPotato.py --daemon --data_dirdir=/var/couchpotato --config_file=/var/couchpotato/couchpotato.ini
;;
stop)
 echo "Shutting down CouchPotato."
  p=`ps aux | grep -v grep | grep CouchPotato.py | tr -s \ | cut -d ' ' -f 2`
  couch_api_key=`grep -m 1 api_key /var/couchpotato/couchpotato.ini | cut -d ' ' -f 3`;
  couch_port=`grep -m 1 port /var/couchpotato/couchpotato.ini | cut -d ' ' -f 3`;
 wget -q --delete-after http://localhost:${couch_port}/api/${couch_api_key}/app.shutdown
 while ps -p $p > /dev/null; do sleep 1; done
;;
*)
 echo "Usage: $0 {start|stop}"
 exit 1
esac
exit 0