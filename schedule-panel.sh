#!/bin/bash
echo "Setting up Go evironmental variables"
echo "" >> ~/.profile
echo "# golang" >> ~/.profile
echo "export GOPATH=/home/pi/go" >> ~/.profile 
echo "export GOSRC=/home/pi/go/src" >> ~/.profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.profile

cd /home/pi/go/src/github.com/byu-oit/av-scheduling-ui

/usr/local/go/bin/go run server.go
