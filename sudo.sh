#!/usr/bin/env bash

# This script is called automatically by `pi-setup.sh` to run a batch of Pi setup commands that require sudo permissions

# Update the time (from google, to ensure https works)
date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"

# Fix the keyboard layout
curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/keyboard > /etc/default/keyboard

echo "Type the desired hostname of this device (E.g. ITB-1006-SP2), followed by [ENTER]:"

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

# Install Salt-Minion on Pi and configure minion to talk to the salt-master
wget -O - https://repo.saltstack.com/apt/debian/8/armhf/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/files/saltstack.list > /etc/apt/sources.list.d/saltstack.list

# Perform general updating
apt update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
apt -y autoclean

sudo apt-get update
sudo apt-get -y install salt-minion

# Copy minion file and add minion
cp /srv/files/minion /etc/salt/minion

#PI_HOSTNAME=$(hostname)
sed -i 's/\$PI_HOSTNAME/'$desired_hostname'/' /etc/salt/minion
echo "$desired_hostname" >> /etc/salt/minion_id
systemctl restart salt-minion

# Patch the Dirty COW kernel vulnerability
# apt -y install raspberrypi-kernel

# Install UI dependencies
apt -y install xorg i3 suckless-tools chromium-browser

# Install python3
apt -y install python3 python3-pip python3-dev python-dev libffi-dev libxml2 libxml2-dev libxslt1-dev libssl-dev

# Default to Python 3
pip3 install --upgrade pip
pip3 install --upgrade setuptools
pip3 install ez_setup lxml
pip3 install maya

# Install an ARM build of docker-compose
#apt -y install python-pip
#easy_install --upgrade pip
pip3 install --upgrade docker-compose



# Configure automatic login for the `pi` user
mkdir -pv /etc/systemd/system/getty@tty1.service.d/
curl https://raw.githubusercontent.com/byuoitav/raspi-deployment-microservice/master/files/autologin.conf > /etc/systemd/system/getty@tty1.service.d/autologin.conf
systemctl enable getty@tty1.service

# Enable SSH connections
touch /boot/ssh
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/files/sshbanner > /etc/sshbanner
sed -ie 's/#Banner \/etc\/issue.net/Banner \/etc\/sshbanner/g' /etc/ssh/sshd_config

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

#sleep 60

#Configure container to run
#docker run -d -p 8011:80 --name="httpd" --restart=always httpd

#Install go
mkdir -p /home/pi/downloads

curl https://storage.googleapis.com/golang/go1.9.linux-armv6l.tar.gz -o /home/pi/downloads/go1.9.linux-armv6l.tar.gz

tar -C /usr/local -xf /home/pi/downloads/go1.9.linux-armv6l.tar.gz

echo "Setting up Go evironment"
mkdir -p ~/go ~/go/src ~/go/bin ~/go/pkg
mkdir -p /home/pi/go /home/pi/go/src /home/pi/go/bin /home/pi/go/pkg

echo "Setting up Go evironmental variables"
echo "" >> ~/.profile
echo "# golang" >> ~/.profile
echo "export GOPATH=/home/pi/go" >> ~/.profile
echo "export GOSRC=/home/pi/go/src" >> ~/.profile
echo "export PATH=$PATH:/usr/local/go/bin:/home/pi/go/bin" >> ~/.profile
source ~/.profile

echo "Setting up Go environment variables for the Pi user"
echo "" >> /home/pi/.profile
echo "# golang" >> /home/pi/.profile
echo "export GOPATH=~/go" >> /home/pi/.profile
echo "export GOSRC=~/go/src" >> /home/pi/.profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> /home/pi/.profile

# Setting up profile aliases
echo "Adding profile aliases"
echo "" >> /home/pi/.profile
echo "alias ll='ls -la'" >> /home/pi/.profile
echo "alias python='python3'" >> /home/pi/.profile
echo "alias pip='pip3'" >> /home/pi/.profile
echo "alias ll='ls -la'" >> /home/pi/.profile
echo "alias PSPORT='netstat -tulpn | grep :'" >> /home/pi/.profile
echo "alias PS='ps -ef | grep -i'" >> /home/pi/.profile
echo "alias NET='netstat -tlapn|grep -e '0.0.0.0:5000' -e '0.0.0.0:8011'"
echo "cd ~/go/src/github.com/byu-oit/av-scheduling-ui" >> /home/pi/.profile
echo "NET" >> /home/pi/.profile

# install Git
apt -y install git

# Change Install Directory
cd /home/pi

# Configure git email and user name for pull requests
git config --global user.email "av-scheduling-dev@byu.edu"
git config --global user.name "AV Services"

# Install GVT
go get -u github.com/FiloSottile/gvt

cd /home/pi/go/src

# Install AV-Scheduling Dependencies
#gvt fetch -branch master github.com/byu-oit/av-scheduling-ui -d
gvt fetch -branch master github.com/byu-oit/av-scheduling-ui

# Install Scheduling-Panel
go get github.com/byu-oit/av-scheduling-ui
go get github.com/byu-oit/av-scheduling-exchange-microservice

# Install microservice dependencies
cd $GOPATH/src/github.com/byu-oit/av-scheduling-exchange-microservice
#pip3 install -r requirements.txt
pip install --ignore-installed --no-cache flask flask-restplus Flask-SQLAlchemy flask_cors exchangelib

# install node-gyp
cd /home/pi
npm i -g npm
npm install -g node-gyp

echo "node-gyp installed moving to install Angular"

cd $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/
#rm -fR node_modules
npm install -g --save --unsafe-perm angular angular-cli
npm install --unsafe-perm

echo "Angular installed . . . ."

cp -fR $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/src/environments/template.environment.ts $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/src/environments/environment.ts
cp -fR $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/src/environments/template.environment.ts $GOPATH/src/github.com/byu-oit/av-scheduling-ui/web/src/environments/environment.prod.ts

# Download Systemd Unit to launch and manage the Scheduling-Panel
curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/scheduling-panel.service > /usr/lib/systemd/system/scheduling-panel.service
systemctl enable scheduling-panel.service

curl https://raw.githubusercontent.com/byu-oit/av-scheduling-panel-deployment/master/schedule-panel.sh > /usr/local/bin/schedule-panel.sh
chmod 754 /usr/local/bin/schedule-panel.sh
chown pi:pi /usr/local/bin/schedule-panel.sh
chown -fR pi:pi /home/pi/.npm

cd $GOPATH/src/github.com/byu-oit
chown -fR pi:pi av-scheduling-ui

# Start the Scheduling-Panel
# go run server.go &


#sleep 60
