#!/bin/bash
echo -e "\e[36mLet's Get Started with certain point release packages!\e[m
"
echo -e "\e[36m---------- Jetbrains Toolbox ----------\e[m
"
echo -e '\e[36mCopy the link address of the "direct link" button link from:\e[m' https://www.jetbrains.com/toolbox-app/download/download-thanks.html
echo -e '\e[36mPaste link address here:\e[m'
read JETBRAINS_TOOLBOX

echo -e '
\e[36mCopy the link address of the "SHA-256 checksum" button link:\e[m'
echo -e '\e[36mPaste link address here:\e[m'
read JETBRAINS_TOOLBOX_CHECKSUM

echo -e '
\e[36m---------- Slack ----------\e[m
'
echo -e '\e[36mCopy the link address of the "Try again" button link from:\e[m' https://slack.com/downloads/instructions/fedora
echo -e '\e[36mPaste link address here:\e[m'
read SLACK

echo -e '
\e[36m---------- Github Setup ----------\e[m
'
echo -e '\e[36mWhat is your name?:\e[m'
read GITHUB_USER_NAME

echo -e '
\e[36mWhat is your email?:\e[m'
read GITHUB_USER_EMAIL

# Set to breeze theme
lookandfeeltool -a 'org.kde.breezedark.desktop'

# Update Files
echo -e '\e[36m---------- Updating packages ----------\e[m'

sudo dnf update -y

#Install Brave
echo -e '\e[36m---------- Installing Brave Browser ----------\e[m'

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

# #Install vscode
echo -e '\e[36m---------- Installing VS Code ----------\e[m'

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code -y

#Install slack
echo -e '\e[36m---------- Installing Slack ----------\e[m'

wget "$SLACK"
sudo rpm -i slack*.rpm
rm slack*.rpm
# Remove unwanted packages
echo -e '\e[36m---------- Removing unwanted packages ----------\e[m'

sudo dnf remove firefox kmahjongg kpat kmines kruler falkon kmail ktorrent k3b calligra-* -y

# Install git, redshift
echo -e '\e[36m---------- Installing wanted packages ----------\e[m'

sudo dnf install git scribus thunderbird flatpak redshift libreoffice xsane plasma-applet-redshift-control -y

#Enable Flatpak
echo -e '\e[36m---------- Enable Flatpak ----------\e[m'
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install Spotify Flatpak
echo -e '\e[36m---------- Installing Spotify ----------\e[m'
sudo flatpak install flathub com.spotify.Client

mkdir ~/Desktop/Programs/

PROGRAM_FOLDER='Desktop/Programs/'

echo -e '\e[36m---------- Installing Jetbrains Toolbox ----------\e[m'

# Get Jetbrains toolbox
wget "$JETBRAINS_TOOLBOX" -P $PROGRAM_FOLDER
wget "$JETBRAINS_TOOLBOX_CHECKSUM" -P $PROGRAM_FOLDER

cd $PROGRAM_FOLDER

# Verify Jetbrains toolbox checksum
if [[ "$(sha256sum -c jetbrains*.sha256)" == *"OK" ]]; then
echo -e '\e[36m---------- Jetbrains checksum OK ----------\e[m'
tar -xvf jetbrains*.tar.gz
rm jetbrains*.tar.gz jetbrains*.sha256
else
echo -e "
\e[1;31m---------- BAD JETBRAINS CHECKSUM ----------
Jetbrains toolbox will not install.
\033[0m"

fi

# Setup git user
git config --global user.name "$GITHUB_USER_NAME"
git config --global user.email "$GITHUB_USER_EMAIL"
git config --global color.ui auto
git config --global color.branch auto
git config --global color.status auto

# Add git branch to terminal
echo "
# Add git branch to end of terminal
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1='[\u@\h] \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ '" >> ~/.bashrc


# Install NVIDIA Drivers
echo -e '\e[36m----------Checking for NVIDIA Graphics ----------\e[m
'
if [[ $(lspci | grep -E "VGA|3D") == *"NVIDIA"* ]]; then
echo -e '\e[36m---------- NVIDIA drivers Found ----------\e[m
'
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan xorg-x11-drv-nvidia-cuda-libs
sudo dnf update -y
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
sudo dnf install https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/nvidia-machine-learning-repo-rhel7-1.0.0-1.x86_64.rpm
sudo dnf install libcudnn7 libcudnn7-devel libnccl libnccl-devel
else
echo -e '\e[36m---------- No NVIDIA drivers found ----------\e[m'
fi



# Reboot system
echo -e '
\e[31m--------- Do not forget to remove VS CODE telemetary ----------
'
for ((countdown=30; countdown>=1; countdown--))
do
echo -n -e "\r\e[31m---------- Installer Finished - Rebooting in $countdown seconds ----------\e[m"
    sleep 1
done
echo''
sudo reboot
