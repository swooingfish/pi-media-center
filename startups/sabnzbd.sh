#!/bin/sh
### BEGIN INIT INFO
# Provides:          SABnzbd
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start SABnzd at boot time
# Description:       Start SABnzbd.
### END INIT INFO

case "$1" in
start)
  echo "Starting SABnzbd."
  /usr/bin/sudo -u sabnzbd -H /usr/local/sabnzbd/SABnzbd.py -d -f /var/sabnzbd/sabnzbd.ini
;;
stop)
  echo "Shutting down SABnzbd."
  p=`ps aux | grep -v grep | grep SABnzbd.py | tr -s \ | cut -d ' ' -f 2`
  if [ -n "$p" ]; then
    kill -2 $p > /dev/null
    while ps -p $p > /dev/null; do sleep 1; done
  fi
;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
esac
exit 0