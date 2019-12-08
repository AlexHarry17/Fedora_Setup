#!/bin/bash

# Set to breeze theme
lookandfeeltool -a 'org.kde.breezedark.desktop'

# Update Files
echo '---------- Updating packages ----------'

sudo dnf update -y

#Install Brave
echo '---------- Installing Brave Browser ----------'

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

#Install vscode
echo '---------- Installing VS Code ----------'

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code -y

# Remove unwanted packages
echo '---------- Removing unwanted packages ----------'

sudo dnf remove firefox kmahjongg kpat kmines kruler falkon kmail ktorrent k3b calligra-* -y

# Install git, redshift
echo '---------- Installing wanted packages ----------'

sudo dnf install git flatpak redshift libreoffice simple-scan plasma-applet-redshift-control redshift-gtk -y

#Enable Flatpak
echo '---------- Enable Flatpak ----------'
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install Spotify Flatpak
echo '---------- Installing Spotify ----------'
sudo flatpak install flathub com.spotify.Client -y

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
echo '---------- Jetbrains checksum OK ----------'
tar -xvf jetbrains*.tar.gz
rm jetbrains*.tar.gz
else
echo '---------- BAD JETBRAINS CHECKSUM ----------'
exit
fi

# Set redshift temperature
echo "
; Global settings for redshift
[redshift]
; Set the day and night screen temperatures
temp-day=4000
temp-night=4000
lat=45.66
lon=111.24
" >> ~/.config/redshift.conf


# Add git branch to terminal
echo "
# Add git branch to end of terminal
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ '" >> ~/.bashrc


# Install NVIDIA Drivers
echo '----------Checking for NVIDIA Graphics ----------'
if [[ $(lspci | grep -E "VGA|3D") == *"NVIDIA"* ]]; then
echo '---------- NVIDIA drivers Found ----------'
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan xorg-x11-drv-nvidia-cuda-libs
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
else
echo '---------- No NVIDIA drivers found ----------'
fi



# Reboot system
echo '
---------- Installer Finished - Please Reboot ----------'

