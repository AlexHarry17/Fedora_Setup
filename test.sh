#!/bin/bash
sudo apt update
cd
wget 'https://downloads.slack-edge.com/linux_releases/slack-desktop-4.2.0-amd64.deb' 
sudo dpkg -i slack*.deb
rm slack*.deb