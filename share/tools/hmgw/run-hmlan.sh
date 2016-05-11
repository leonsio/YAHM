#!/bin/sh
#cd /root/hmgw
cd /home/pi/hmgw
sudo killall -w hmlangw
sudo ./hmlangw -n auto 1> /dev/null 2> /dev/null &

