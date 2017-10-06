#!/usr/bin/env bash

# This script is called automatically by `pi-setup.sh` to run a batch of Pi setup commands that require sudo permissions

# Update the time (from google, to ensure https works)
date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

# Fix the keyboard layout
curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/keyboard > /etc/default/keyboard

echo "Type the desired hostname of this device (E.g. ITB-1006-CP2), followed by [ENTER]:"

read -e desired_hostname

echo $desired_hostname > /etc/hostname
echo "127.0.1.1    $desired_hostname" >> /etc/hosts

# get static ip
#echo "Type the desired static ip-address of this device (E.g. 10.5.99.18), followed by [ENTER]:"

#read -e desired_ip

#echo "interface eth0" >> /etc/dhcpcd.conf
#echo "static ip_address=$desired_ip/24" >> /etc/dhcpcd.conf
#routers=$(echo "static routers=$desired_ip" | cut -d "." -f -3)
#echo "$routers.1" >> /etc/dhcpcd.conf
#echo "static domain_name_servers=10.8.0.19 10.8.0.26" >> /etc/dhcpcd.conf

# set contact points up
# curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/image/contacts.service > /usr/lib/systemd/system/contacts.service
# chmod 664 /usr/lib/systemd/system/contacts.service
# curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/contacts.py > /usr/bin/contacts.py
# chmod 775 /usr/bin/contacts.py
# systemctl daemon-reload

# set up screenshutoff
# curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/screenshutoff-setup.sh > /tmp/sss-setup.sh
# chmod +x /tmp/sss-setup.sh
# sh -c "bash /tmp/sss-setup.sh"

# Perform general updating
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
apt -y autoclean

# Patch the Dirty COW kernel vulnerability
apt -y install raspberrypi-kernel

# Install UI dependencies
apt -y install xorg i3 suckless-tools chromium-browser

# Install an ARM build of docker-compose
#apt -y install python-pip
#easy_install --upgrade pip
#pip install docker-compose

# Install Salt-Minion on Pi and configure minion to talk to the salt-master
wget -O - https://repo.saltstack.com/apt/debian/8/armhf/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/files/saltstack.list > /etc/apt/sources.list.d/saltstack.list
#cp /srv/files/saltstack.list /etc/apt/sources.list.d/saltstack.list

sudo apt-get update
sudo apt-get -y install salt-minion

# Copy minion file and add minion
cp /srv/files/minion /etc/salt/minion
#PI_HOSTNAME=$(hostname)
sed -i 's/\$PI_HOSTNAME/'$desired_hostname'/' /etc/salt/minion
systemctl restart salt-minion

# Configure automatic login for the `pi` user
mkdir -pv /etc/systemd/system/getty@tty1.service.d/
curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/autologin.conf > /etc/systemd/system/getty@tty1.service.d/autologin.conf
systemctl enable getty@tty1.service

# Enable SSH connections
touch /boot/ssh

# Set the timezone
cp /usr/share/zoneinfo/America/Denver /etc/localtime

# Add the `pi` user to the sudoers group
usermod -aG sudo pi

# install golang
#apt -y install golang

# Install docker for arm and set Pi user as a member of the docker group
# until $(sudo usermod -aG docker pi); do
#	curl -sSL https://get.docker.com -k | sh
#	wait
#done
#echo "Added docker and user pi to the docker group"

# set to update from byu servers
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/ntp.conf > /etc/ntp.conf
apt -y install ntpdate
systemctl stop ntp
ntpdate-debian
systemctl start ntp
ntpq -p

# Node.js 8 installation
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

#Download docker container
#docker image pull httpd

sleep 60

#Configure container to run
#docker run -d -p 8011:80 --name="httpd" --restart=always httpd

#Install go
wget --no-check-certificate https://storage.googleapis.com/golang/go1.9.linux-armv6l.tar.gz > /tmp/go1.9.linux-armv6l.tar.gz
cd /tmp
sudo tar -C /usr/local -xzf go1.9.linux-armv6l.tar.gz

# install Git
sudo apt install git

# Install GVT
go get -u github.com/FiloSottile/gvt

# Install AV-Scheduling Dependencies
#gvt fetch -branch master github.com/byu-oit/av-scheduling-ui -d
gvt fetch -branch master github.com/byu-oit/av-scheduling-ui

# Install Scheduling-Panel
go get github.com/byu-oit/av-scheduling-ui
cd $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/
npm install --save

# Start the Scheduling-Panel
go run server.go &

#sleep 60
