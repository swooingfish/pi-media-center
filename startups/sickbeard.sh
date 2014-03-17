#!/bin/sh
### BEGIN INIT INFO
# Provides:          SickBeard
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start SickBeard at boot time
# Description:       Start SickBeard.
### END INIT INFO

case "$1" in
start)
  echo "Starting SickBeard."
  /usr/bin/sudo -u sickbeard -H /usr/local/sickbeard/SickBeard.py -d --datadir /var/sickbeard --config /var/sickbeard/sickbeard.ini
;;
stop)
  echo "Shutting down SickBeard."
  p=`ps aux | grep -v grep | grep SickBeard.py | tr -s \ | cut -d ' ' -f 2`
  if [ -n "$p" ]; then
    sb_api_key=`grep -m 1 api_key ${sb_config} | cut -d ' ' -f 3`;
    sb_port=`grep -m 1 web_port ${sb_config} | cut -d ' ' -f 3`;
    wget -q --delete-after http://localhost:${sb_port}/api/${sb_api_key}/\?cmd=sb.shutdown
    while ps -p $p > /dev/null; do sleep 1; done
  fi
;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
esac

exit 0