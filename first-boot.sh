#!/bin/bash
# This script should live in /usr/bin/ on the rasbian img. It will run once on the first boot of the pi, and then disable the service.

sleep 15

printf "\n\nDownloading the Goods\n\n"

sudo chvt 2

#bootfile="/usr/local/games/firstboot"

#if [ -f "$bootfile" ]; then
	echo "First boot."

	# download pi-setup script
	#until $(curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/pi-setup.sh > /tmp/pi-setup.sh); do
	#	sleep 30
	#	echo "Trying again."
	#done
############# Production - Pull from Master #####################
#	while true; do
#    curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/pi-setup.sh > /tmp/pi-setup.sh
#    if [ $? -eq 0 ]; then
#        break
#    fi
#    sleep 5
#  done
#################################################################
############## Test Code ########################################
  while true; do
  curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/feature/docker_support/pi-setup.sh > /tmp/pi-setup.sh
   if [ $? -eq 0 ]; then
        break
   fi
   sleep 5
   done
#################################################################
	#curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/pi-setup.sh > /tmp/pi-setup.sh

	#sudo cp /srv/scripts/pi-setup.sh /tmp/pi-setup.sh
	sudo chmod 755 /tmp/pi-setup.sh

#	echo "Removing first boot file."
#	sudo rm $bootfile

	echo "Running PI setup script . . ."
	/tmp/pi-setup.sh
#else
#	echo "Second boot."
#
#	sleep 5
#	sudo chvt 2
#
#	# download second-boot script
#	until $(curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/second-boot.sh > /tmp/second-boot.sh); do
#		echo "Trying again."
#	done
#	chmod +x /tmp/second-boot.sh
#
#	/tmp/second-boot.sh
#
	echo "Removing symlink to startup script."
	sudo rm /usr/lib/systemd/system/default.target.wants/first-boot.service
#fi

clear
printf "\n\n\n\n\n\n"
printf "Setup complete! I'll never see you again."
printf "\n\tPlease wait for me to reboot.\n"
sleep 20
printf "\n\nBye lol"
sleep 5

sudo sh -c "reboot"
