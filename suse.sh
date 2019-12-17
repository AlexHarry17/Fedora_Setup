#!/bin/bash
DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FILE=$(basename $BASH_SOURCE) 
cd

print_good_output () {
echo -e "
\e[36m---------- $1 ----------\e[m
"
}

print_error_output () {
echo -e "
\e[1;31m---------- $1 ----------\033[0m
"
}

print_no_format_link() {
  echo -e "\e[36m$1 \e[m" $2  
}

print_no_format() {
  echo -en "\e[36m$1 \e[m" 
}

# Brother Printer Setup
brother_printer_setup () {
brother_printer=''
while true;
do
print_no_format "Do you want to set up a Brother Printer? [y/N]"
read brother_printer
if [[ $brother_printer = 'y' ]]; then
brother_printer='y'
print_no_format_link 'Vist the following link. Search for your model.  Choose the "Driver Install Tool".  Read and agree to the license. Copy the link address of "If your download does not start automatically, please click here.":' 'https://support.brother.com/g/b/productsearch.aspx?c=us&lang=en&content=dl'
print_no_format 'Paste link address here:'
read BROTHER_DRIVER
print_no_format 'Enter your printer model:'
read BROTHER_MODEL
break
fi
if [[ $brother_printer = 'n' ]] || [[ -z $brother_printer ]] || [[ $brother_printer = 'N' ]]; then
break
else
print_error_output "Enter 'y' for yes or 'n' for no"
fi
done
}

# Upgrades the packages of the freshly installed systems
update_package() {
print_good_output "Upgrading packages"
sudo zypper dup -y
}

git_lfs() {
wget "$GIT_LFS"
tar -xvf git-lfs*.tar.gz
sudo bash install.sh
rm CHANGELOG.md git-lfs install.sh README.md git-lfs*.tar.gz
}

# Removes all packages passed into the function
remove_package() {
# source for $@: https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script, user Robert Gamble
for package in "$@"
do
print_good_output "Removing package $package"
sudo zypper rm -y $package
# Lock packages from reinstalling on updates
sudo zypper al $package
done
}

# Installs all packages passed into the function
install_package() {
# source for $@: https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script, user Robert Gamble
for package in "$@"
do
print_good_output "Installing package $package"
sudo zypper install -y $package
done
}

# Install packages with license agreements
install_package_license_aggrements() {
accepted=''
while [[ $accepted != 'yes' || $accepted != 'no' ]]; do
print_no_format "
$2 Requires Accepting a License."
print_no_format "
You must read and accept this license to install and use $2."
print_no_format "
If you do not accept, $2 will not be installed."
print_no_format_link "
Read the $2 license:" $3
print_no_format "
I've read and accept the $2 license: [yes/no]"
read accepted
if [[ $accepted = 'yes' || $accepted = 'no' ]]; then
break
else
print_error_output "You must type 'yes' or 'no' to the $2 license"
fi
done

if [[ $accepted = 'yes' ]]; then
if [[ $2 = 'Spotify' ]]; then
install_snapd
print_no_format "Installing Spotify"
sudo snap install spotify
elif [[ $2 = 'Visual Studio Code' ]]; then
install_code
elif [[ $2 = 'nvidia-tumbleweed' ]]; then
zypper ar https://download.nvidia.com/opensuse/tumbleweed nvidia-tumbleweed
zypper inr
fi
else
print_error_output "$2 will not be installed"
fi
}

install_code() {
print_no_format "Installing VS Code"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/zypp/repos.d/vscode.repo'
sudo zypper refresh
install_package code
}

#Install Snapd package
install_snapd() {
sudo zypper addrepo --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
install_package snapd
sudo systemctl enable snapd
sudo systemctl start snapd
sudo systemctl enable snapd.apparmor
sudo systemctl start snapd.apparmor
}

# Install the jetbrains toolbox
install_jetbrains_toolbox() {
mkdir ~/Desktop/Programs/

PROGRAM_FOLDER='Desktop/Programs/'

print_good_output "Installing Jetbrains Toolbox"

# Get Jetbrains toolbox
wget "$JETBRAINS_TOOLBOX" -P $PROGRAM_FOLDER
wget "$JETBRAINS_TOOLBOX_CHECKSUM" -P $PROGRAM_FOLDER

cd $PROGRAM_FOLDER

# Verify Jetbrains toolbox checksum
if [[ "$(sha256sum -c jetbrains*.sha256*)" == "jetbrains-toolbox"*"OK" ]]; then
print_good_output "Jetbrains checksum OK"
tar -xvf jetbrains*.tar.gz*

else
print_error_output "BAD JETBRAINS CHECKSUM"
print_error_output "Jetbrains toolbox will not install."
fi

rm jetbrains*.tar.gz* jetbrains*.sha256*
}

# Configures the git config settings
git_config() {
git config --global user.name "$GITHUB_USER_NAME"
git config --global user.email "$GITHUB_USER_EMAIL"
git config --global credential.helper cache
git config --global credential.helper "cache --timeout=3600"
}

# Installs additional cuda libraries for nvidia
install_nvidia() {
# Install NVIDIA Drivers
echo -e '\e[36m----------Checking for NVIDIA Graphics ----------\e[m
'
if [[ $(lspci | grep -E "VGA|3D") == *"NVIDIA"* ]]; then
print_good_output "NVIDIA Graphics Found"
install_package_license_aggrements nvidia-tumbleweed "nvidia-tumbleweed" https://download.nvidia.com/opensuse/tumbleweed/NVIDIA-LICENSE
sudo conda create --name tf_gpu tensorflow-gpu 
fi
}

# Runs through the brother printer installer
install_brother_printer() {
if [[ $brother_printer = 'y' ]]; then
print_good_output "Installing Brother Printer"
wget "$BROTHER_DRIVER"
gunzip linux-brprinter-installer-*.*.*-*.gz
sudo bash linux-brprinter-installer-*.*.*-* $BROTHER_MODEL
rm linux-brprinter-installer* brscan*.rpm cupswrapper*.rpm mfc*.rpm
fi
}

# Sets up bash config
setup_bash(){
# Clone the bash_it repo
print_good_output "Setting up bash settings"
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh <<EOF
N
EOF

# Add blinking I-beam cursor 
echo "
# Add blinking ibeam cursor
echo -ne '\e[5 q'
" >> ~/.bashrc

# Sets the desired bash_it theme
sed -i -e "s/export BASH_IT_THEME='bobby'/export BASH_IT_THEME='powerline-plain'/g" ~/.bashrc
}

# Opens jetbrains-toolbox to create icon launcher.  Opens code to configure settings.
open_files() {
cd ~/$PROGRAM_FOLDER/jetbrains*
./jetbrains-tool*
sleep 3
xdotool windowminimize $(xdotool getactivewindow)
code
sleep 6
xdotool windowminimize $(xdotool getactivewindow)
}

# A countdown for reboot.
reboot_countdown() {
# Reboot system
for ((countdown=30; countdown>=1; countdown--))
do
echo -n -e "\r\e[31m---------- Installer Finished - Rebooting in $countdown seconds ----------\e[m"
    sleep 1
done
reboot
}

# Sets VS code settings to auto save, removes telemetry, and sets the color scheme
code_settings(){
echo '{
    "files.autoSave": "afterDelay",
    "telemetry.enableCrashReporter": false,
    "telemetry.enableTelemetry": false,
    "workbench.colorTheme": "Monokai"
}' >> ~/.config/Code/User/settings.json
}

kde_settings() {
lookandfeeltool -a 'org.kde.breezedark.desktop'
}

#Install slack
install_slack() {
print_good_output "Installing Slack"
wget "$SLACK"
sudo rpm -i slack*.rpm
rm slack*.rpm
}
print_good_output "Lets Get Started!"
print_good_output "Jetbrains Toolbox"
print_no_format_link 'Copy the link address of the "direct link" button link from:' https://www.jetbrains.com/toolbox-app/download/download-thanks.html
print_no_format 'Paste link address here:'
read JETBRAINS_TOOLBOX

print_no_format 'Copy the link address of the "SHA-256 checksum" button link.'
print_no_format 'Paste link address here:'
read JETBRAINS_TOOLBOX_CHECKSUM

print_good_output "Slack"
print_no_format_link 'Copy the link address of the "Try again" button link from:' https://slack.com/downloads/instructions/fedora
print_no_format 'Paste link address here:'
read SLACK

print_good_output "GIT-LFS"
print_no_format_link 'Copy the link address of the "Download v*.*.* (Linux)" button link from:' https://git-lfs.github.com/
print_no_format 'Paste link address here:'
read GIT_LFS

print_good_output "Github Setup"
print_no_format "What is your name?:"
read GITHUB_USER_NAME

print_no_format "What is your email?:"
read GITHUB_USER_EMAIL

brother_printer_setup
update_package
remove_package MozillaFirefox kmahjongg kpat kreversi kmines ksudoku akregator kmail vlc kcm_tablet
install_package xdotool libappindicator-gtk3 curl scribus libappindicator1 MozillaThunderbird chromium dkms
install_package_license_aggrements spotify-client "Spotify" https://www.spotify.com/us/legal/end-user-agreement/ 
install_package_license_aggrements code "Visual Studio Code" https://code.visualstudio.com/License
install_slack
git_lfs
install_jetbrains_toolbox
install_nvidia
install_brother_printer
open_files
code_settings
change_settings
tweak_extension_settings
git_config
setup_bash
#Remove this script file
cd $DIRECTORY
rm $FILE
reboot_countdown

