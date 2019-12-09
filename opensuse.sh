#!/bin/bash

# Set to breeze theme
lookandfeeltool -a 'org.kde.breezedark.desktop'

# Update Files
echo '
---------- Updating packages ----------
'

sudo zypper dup -y

#Install vscode
echo '
---------- Installing VS Code ----------
'

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
sudo zypper install -y code

# Remove unwanted packages
echo '
---------- Removing unwanted packages ----------
'

sudo zypper rm -y MozilaFirefox kmahjongg kpat kreversi kmines ksudoku akregator kmail vlc kcm_tablet

# Lock packages from reinstalling
sudo zypper al MozilaFirefox kmahjongg kpat kreversi kmines ksudoku akregator kmail vlc kcm_tablet

# Install git, redshift
echo '
---------- Installing wanted packages ----------
'

sudo zypper install -y git flatpak

#Enable Flatpak
echo '
---------- Enable Flatpak ----------
'
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install Spotify Flatpak
echo '
---------- Installing Spotify ----------
'
sudo flatpak install flathub com.spotify.Client

mkdir ~/Desktop/Programs/

PROGRAM_FOLDER='Desktop/Programs/'

# Get Jetbrains toolbox
wget 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6067.tar.gz' -P $PROGRAM_FOLDER
wget 'https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.16.6067.tar.gz.sha256' -P $PROGRAM_FOLDER

cd $PROGRAM_FOLDER

CHECK="$(sha256sum -c jetbrains*.sha256)"
echo "$CHECK"
# Verify Jetbrains toolbox checksum
if [[ "$(sha256sum -c jetbrains*.sha256)" == *"OK" ]]; then
echo '
---------- Jetbrains checksum OK ----------
'
tar -xvf jetbrains*.tar.gz
rm jetbrains*.tar.gz jetbrains*.sha256sum
else
echo '
---------- BAD JETBRAINS CHECKSUM ----------
'
exit
fi

# Add git branch to terminal
echo "
# Add git branch to end of terminal
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='[\u@\h] \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ '" >> ~/.bashrc


# Reboot system
echo '
---------- Installer Finished - Please Reboot ----------'
