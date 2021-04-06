#!/bin/bash

HOME_PRJ=/home/pprz/Projects/compagnon-software/
HOME_WFB=$HOME_PRJ/wifibroadcast
PIDFILE=/tmp/wfb.pid

if [ -n "$1" ]; then

  wl=$1

  $HOME_WFB/wfb_tx -K $HOME_WFB/drone.key -p 1 -u 5700 $wl > /dev/null 2>&1 &
  echo $! > $PIDFILE
  $HOME_WFB/wfb_tx -K $HOME_WFB/drone.key -p 2 -u 4244 -k 1 -n 2 $wl > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  $HOME_WFB/wfb_rx -K $HOME_WFB/drone.key -p 3 -u 4245 -c 127.0.0.1 -k 1 -n 2 $wl > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  $HOME_WFB/wfb_rx -K $HOME_WFB/drone.key -p 4 -u 14901 -c 127.0.0.1 -k 1 -n 2 $wl > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  $HOME_WFB/wfb_tx -K $HOME_WFB/drone.key -p 5 -u 14900 -k 1 -n 2 $wl > /dev/null 2>&1 &
  echo $! >> $PIDFILE

  if uname -a | grep -cs "4.9"> /dev/null 2>&1;then $HOME_PRJ/scripts/air_camjet.sh;
  else $HOME_PRJ/scritps/air_campi.sh;fi

  socat -u /dev/ttyAMA0,raw,echo=0,b115200 udp-sendto:127.0.0.1:4244 > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  socat -u udp-listen:4245,reuseaddr,fork /dev/ttyAMA0,raw,echo=0,b115200 > /dev/null 2>&1 &
  echo $! >> $PIDFILE

  socat TUN:10.0.1.2/24,tun-name=airtuntx,iff-no-pi,tun-type=tun,iff-up udp-sendto:127.0.0.1:14900 > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  socat udp-listen:14901,reuseaddr,fork TUN:10.0.1.2/24,tun-name=airtunrx,iff-no-pi,tun-type=tun,iff-up > /dev/null 2>&1 &
  echo $! >> $PIDFILE
  sleep 1
  ifconfig airtuntx mtu 1400 up &

  while [ ! "`sysctl -w net.ipv4.conf.airtunrx.rp_filter=2`" = "net.ipv4.conf.airtunrx.rp_filter = 2" ];do sleep 1; done

fi