#!/bin/bash

# This script is used to install and set up dependencies on a newly wiped/installed Raspberry Pi
# For clean execution, run this script inside of the /tmp directory with `./pi-setup.sh`
# The script assumes the username of the autologin user is "pi"

# Run the `sudo.sh` code block to install necessary packages and commands
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/sudo.sh > /tmp/sudo.sh
#sudo cp /srv/scripts/sudo.sh /tmp/sudo.sh
chmod +x /tmp/sudo.sh
sudo sh -c "bash /tmp/sudo.sh"

# Make `startx` result in starting the i3 window manager
curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/xinitrc > /home/pi/.xinitrc
chmod +x /home/pi/.xinitrc

# Download the script necessary to update Docker containers after a reboot
# curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/update_docker_containers.sh > /home/pi/update_docker_containers.sh
# chmod +x /home/pi/update_docker_containers.sh

# Configure i3
mkdir /home/pi/.i3
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/files/i3_config > /home/pi/.i3/config
#sudo cp /srv/files/i3_config /home/pi/.i3/config

#### Unneeded at this point ####
# Install an ARM-specific Docker version
#curl -sSL http://downloads.hypriot.com/docker-hypriot_1.10.3-1_armhf.deb > /tmp/docker-hypriot_1.10.3-1_armhf.deb
#sudo sh -c "dpkg -i /tmp/docker-hypriot_1.10.3-1_armhf.deb; usermod -aG docker pi; systemctl enable docker.service"

# Make X start on login
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/files/bash_profile > /home/pi/.bash_profile
#cp /tmp/bash_profile /home/pi/.bash_profile

#Trying to switch user to pi
#su pi

# source the new exports
#source ~/.profile

# Install GVT
#go get -u github.com/FiloSottile/gvt

# Install AV-Scheduling Dependencies
#gvt fetch -branch master github.com/byu-oit/av-scheduling-ui -d
#gvt fetch -branch master github.com/byu-oit/av-scheduling-ui

# Install Scheduling-Panel
#go get github.com/byu-oit/av-scheduling-ui
#cd $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/
#sudo npm install --save

#sudo sh -c "reboot"
