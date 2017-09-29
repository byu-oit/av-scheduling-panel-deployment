#!/bin/bash

mount ~/Desktop/2017-07-05-raspbian-jessie-lite.img -o offset=$[512*94208] /media/jessie
sleep 10

cp '/home/creeder/Desktop/Room_Scheduler_Pi/first-boot.sh' /media/jessie/usr/bin
cp '/home/creeder/Desktop/Room_Scheduler_Pi/pi-setup.sh' /media/jessie/srv/scripts/
cp '/home/creeder/Desktop/Room_Scheduler_Pi/sudo.sh' /media/jessie/srv/scripts/
cp '/home/creeder/Desktop/Room_Scheduler_Pi/config_files/minion' /media/jessie/srv/files/minion
cp '/home/creeder/Desktop/Room_Scheduler_Pi/config_files/i3_config' /media/jessie/srv/files/i3_config
cp '/home/creeder/Desktop/Room_Scheduler_Pi/config_files/saltstack.list' /media/jessie/srv/files/saltstack.list

cp '/home/creeder/Desktop/Room_Scheduler_Pi/first-boot.service' /media/jessie/usr/lib/systemd/system/ 

ln -s /media/jessie/usr/lib/systemd/system/first-boot.service /media/jessie/usr/lib/systemd/system/default.target.wants/first-boot.service

chmod 755 /media/jessie/usr/lib/systemd/system/first-boot.service
chmod 755 /media/jessie/usr/bin/first-boot.sh
chmod 755 /media/jessie/srv/scripts/pi-setup.sh
chmod 755 /media/jessie/srv/scripts/sudo.sh
sleep 10
umount /media/jessie


