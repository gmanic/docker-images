#!/bin/bash

old_IP_File="/srv/womo_ip"
if [ -s $old_IP_File ]; then
  old_IP=`cat $old_IP_File`
fi

IP_TOCHECK="192.168.100.100 192.168.100.101 192.168.100.102 192.168.100.103 192.168.100.104 192.168.100.105"

if [ -s $old_IP_File ]; then
  if [ "x`curl -s -I --user admin:admin http://$old_IP/tempfs/snap.jpg|grep Hipcam`" != "x" ]; then
    curl -s -o /srv/zoneminder/snap.jpg -u admin:admin http://$old_IP/tempfs/snap.jpg
  else
    rm $old_IP_File
  fi
else
  for i in $IP_TOCHECK; do
    if [ "x`curl -s -I -u admin:admin http://$i/tempfs/snap.jpg|grep Hipcam`" != "x" ]; then
      curl -s -o /srv/zoneminder/snap.jpg -u admin:admin http://$i/tempfs/snap.jpg
      echo $i > $old_IP_File
      break
    fi
  done
fi

curl -s -o /srv/zoneminder/snap2.jpg -u viewer:viewer "http://192.168.250.22/cgi-bin/api.cgi?cmd=Snap&channel=0&width=2560&height=1920&rs=21343&user=viewer&password=viewer"
