#!/bin/bash

print_good_output () {
echo -e "\e[36m---------- $1 ----------\e[m
"
}

print_error_output () {
echo -e "\e[1;31m---------- $1 ----------\033[0m
"
}

print_good_output "Lets Get Started!"
print_good_output "Jetbrains Toolbox"
echo -e '\e[36mCopy the link address of the "direct link" button link from:\e[m' https://www.jetbrains.com/toolbox-app/download/download-thanks.html
echo -e '\e[36mPaste link address here:\e[m'
read JETBRAINS_TOOLBOX

echo -e '
\e[36mCopy the link address of the "SHA-256 checksum" button link:\e[m'
echo -e '\e[36mPaste link address here:\e[m'
read JETBRAINS_TOOLBOX_CHECKSUM

print_good_output "Slack"

echo -e '\e[36mCopy the link address of the "Try again" button link from:\e[m' https://slack.com/downloads/instructions/fedora
echo -e '\e[36mPaste link address here:\e[m'
read SLACK

print_good_output "Github Setup"
print_good_output "What is your name?:"
read GITHUB_USER_NAME

print_good_output "What is your email?:"
read GITHUB_USER_EMAIL

# Ask for brother printer install
brother_printer=''
echo -en "\e[36mDo you want to set up a Brother Printer? [y/n] \033[0m"

while true;
do
read brother_printer
if [ $brother_printer = 'y' ]; then
echo -e '\e[36mVist the following link. Search for your model.  Choose the "Driver Install Tool".  Read and agree to the license. Copy the link address of "If your download does not start automatically, please click here.":\e[m' 'https://support.brother.com/g/b/productsearch.aspx?c=us&lang=en&content=dl'
echo -e '\e[36mPaste link address here:\e[m'
read BROTHER_DRIVER
echo -e '\e[36mEnter your printer model:\e[m'
read BROTHER_MODEL
break
fi
if [ $brother_printer = 'n' ]; then
break
else
print_error_output "Enter 'y' for yes or 'n' for no"
fi

# Update Files
print_good_output "Updating packages"

sudo dnf update -y

#Install Brave
print_good_output "Installing Brave Browser"

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser -y

# #Install vscode
print_good_output "Installing VS Code"

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code -y

#Install slack
print_good_output "Installing Slack"

wget "$SLACK"
sudo rpm -i slack*.rpm
rm slack*.rpm
# Remove unwanted packages
print_good_output "Removing unwanted packages"

sudo dnf remove firefox konqueror akregator kamoso kmouth konversation juk dragon kmahjongg kwrite kpat kmines kruler falkon kmail ktorrent k3b calligra-* -y

# Install git, redshift
print_good_output "Installing wanted packages"

sudo dnf install @kde-desktop-environment git scribus thunderbird flatpak redshift libreoffice xsane plasma-applet-redshift-control -y

#Enable Flatpak
print_good_output "Enable Flatpak"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#Install Spotify Flatpak
print_good_output "Installing Spotify"
sudo flatpak install flathub com.spotify.Client -y

mkdir ~/Desktop/Programs/

PROGRAM_FOLDER='Desktop/Programs/'

print_good_output "Installing Jetbrains Toolbox"

# Get Jetbrains toolbox
wget "$JETBRAINS_TOOLBOX" -P $PROGRAM_FOLDER
wget "$JETBRAINS_TOOLBOX_CHECKSUM" -P $PROGRAM_FOLDER

cd $PROGRAM_FOLDER

# Verify Jetbrains toolbox checksum
if [[ "$(sha256sum -c jetbrains*.sha256)" == *"OK" ]]; then
print_good_output "Jetbrains checksum OK"
tar -xvf jetbrains*.tar.gz
rm jetbrains*.tar.gz jetbrains*.sha256

else
print_error_output "BAD JETBRAINS CHECKSUM"
print_error_output "Jetbrains toolbox will not install."

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
print_good_output "NVIDIA drivers Found"
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan xorg-x11-drv-nvidia-cuda-libs
sudo dnf update -y
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
sudo dnf install https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/nvidia-machine-learning-repo-rhel7-1.0.0-1.x86_64.rpm
sudo dnf install libcudnn7 libcudnn7-devel libnccl libnccl-devel
else
print_good_output "No NVIDIA drivers found"
fi

if [ $brother_printer = 'y' ]; then
wget "$BROTHER_DRIVER"
gunzip linux-brprinter-installer-*.*.*-*.gz
sudo bash linux-brprinter-installer-*.*.*-* $BROTHER_MODEL
rm linux-brprinter-installer* brscan*.rpm cupswrapper*.rpm mfc*.rpm
fi


programs_started=false
# Reboot system
for ((countdown=30; countdown>=1; countdown--))
do
echo -n -e "\r\e[31m---------- Installer Finished - Rebooting in $countdown seconds ----------\e[m"
    sleep 1
if [ $programs_started != true ]  &&  (( countdown <= 5 )); then
    cd jetbrains*
    ./jetbrains-tool*
    code
    programs_started=true
fi
done
echo''
#VSCode Settings
echo '{
    "files.autoSave": "afterDelay",
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false,
    "workbench.colorTheme": "Monokai"
}' >> ~/.config/Code/User/settings.json

sudo reboot
