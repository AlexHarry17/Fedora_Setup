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
kde_wanted () {
kde_desktop=''
while true;
do
print_no_format "Do you want to install KDE Desktop? [y/N]"
read kde_desktop
if [[ $kde_desktop = 'y' ]] || [[ $kde_desktop = 'n' ]] || [[ -z $kde_desktop ]] || [[ $kde_desktop = 'N' ]] ; then
break
else
print_error_output "Enter 'y' for yes or 'n' for no"
fi
done
}

# Brother Printer Setup
brother_printer_setup () {
brother_printer=''
while true;
do
print_no_format "Do you want to set up a Brother Printer? [y/N]"
read brother_printer
if [ $brother_printer = 'y' ]; then
brother_printer='y'
print_no_format_link 'Vist the following link. Search for your model.  Choose the "Driver Install Tool".  Read and agree to the license. Copy the link address of "If your download does not start automatically, please click here.":' 'https://support.brother.com/g/b/productsearch.aspx?c=us&lang=en&content=dl'
print_no_format 'Paste link address here:'
read BROTHER_DRIVER
print_no_format 'Enter your printer model:'
read BROTHER_MODEL
break
fi
if [[ $brother_printer = 'n'  || -z $brother_printer ]]; then
break
else
print_error_output "Enter 'y' for yes or 'n' for no"
fi
done
}

# Upgrades the packages of the freshly installed systems
initial_package_upgrade() {
print_good_output "Upgrading packages"
sudo apt update && sudo apt upgrade -y --allow-downgrades && sudo apt autoremove -y
}

# Removes all packages passed into the function
remove_package() {
# source for $@: https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script, user Robert Gamble
for package in "$@"
do
print_good_output "Removing package $package"
sudo apt remove $package -y
done
sudo apt autoremove -y 
}

# Installs all packages passed into the function
install_package() {
# source for $@: https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script, user Robert Gamble
for package in "$@"
do
sudo apt update
print_good_output "Installing package $package"
sudo apt install $package -y
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

if [ $accepted = 'yes' ]; then
sudo apt update
print_good_output "Installing package $1"
sudo apt install $1
else
print_error_output "$2 will not be installed"
fi
}


# Install the brave browser
install_brave_browser() {
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
install_package brave-browser
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
if [[ "$(sha256sum -c jetbrains*.sha256)" == "jetbrains-toolbox"*"OK" ]]; then
print_good_output "Jetbrains checksum OK"
tar -xvf jetbrains*.tar.gz

else
print_error_output "BAD JETBRAINS CHECKSUM"
print_error_output "Jetbrains toolbox will not install."
fi

rm jetbrains*.tar.gz jetbrains*.sha256
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
install_package system76-cuda-latest system76-cudnn-*.*
fi
}

# Runs through the brother printer installer
install_brother_printer() {
if [ $brother_printer = 'y' ]; then
print_good_output "Installing Brother Printer"
wget "$BROTHER_DRIVER"
gunzip linux-brprinter-installer-*.*.*-*.gz
sudo bash linux-brprinter-installer-*.*.*-* $BROTHER_MODEL
rm linux-brprinter-installer* brscan*.deb cupswrapper*.deb mfc*.deb
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
sleep 5
xdotool windowminimize $(xdotool getactivewindow)
code
sleep 5
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

# Creates settings via desktop entry
change_settings() {
echo '[Desktop Entry]
Type=Application
Name=Show Desktop
Icon=desktop
Exec=xdotool key --clearmodifiers Super+d' >> ~/.local/share/applications/show-desktop.desktop
}

# Edit gsettings/tweak settings
tweak_extension_settings() {
print_good_output "Tweaking Gnome Settings"
# Tweak Settings
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 04.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 03.98333333
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
gsettings set org.gnome.desktop.interface gtk-theme Pop-dark
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.notifications show-in-lock-screen true
gsettings set org.gnome.system.location enabled false
gsettings set org.gnome.desktop.privacy remove-old-trash-files true
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.peripherals.touchpad click-method areas
gsettings set org.gnome.shell enabled-extensions "['alt-tab-raise-first-window@system76.com', 'always-show-workspaces@system76.com', 'batteryiconfix@kylecorry31.github.io', 'donotdisturb@kylecorry31.github.io', 'pop-shop-details@system76.com', 'pop-suspend-button@system76.com', 'system76-power@system76.com', 'ubuntu-dock@ubuntu.com']"
gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'thunderbird.desktop', 'spotify.desktop', 'slack.desktop', 'jetbrains-toolbox.desktop', 'code.desktop', 'org.gnome.Nautilus.desktop', 'show-desktop.desktop']"
}


print_good_output "Lets Get Started!"
kde_wanted
print_good_output "Jetbrains Toolbox"
print_no_format_link 'Copy the link address of the "direct link" button link from:' https://www.jetbrains.com/toolbox-app/download/download-thanks.html
print_no_format 'Paste link address here:'
read JETBRAINS_TOOLBOX

print_no_format 'Copy the link address of the "SHA-256 checksum" button link.'
print_no_format 'Paste link address here:'
read JETBRAINS_TOOLBOX_CHECKSUM

print_good_output "Github Setup"
print_no_format "What is your name?:"
read GITHUB_USER_NAME

print_no_format "What is your email?:"
read GITHUB_USER_EMAIL

brother_printer_setup
initial_package_upgrade
remove_package gedit gnome-weather firefox geary

if [ kde_desktop = 'y' ]
install_package kde-plasma-desktop
remove_package gwenview imagemagick akregator kmail kopete dragonplayer kcalc kate juk
fi

install_package xdotool gparted slack-desktop redshift plasma-applet-redshift-control tensorman apt-transport-https curl git-lfs deja-dup synaptic gconf2 libdbusmenu-gtk4 scribus libappindicator1 thunderbird gnome-tweaks gnome-shell-extension-ubuntu-dock
install_package_license_aggrements spotify-client "Spotify" https://www.spotify.com/us/legal/end-user-agreement/ 
install_package_license_aggrements code "Visual Studio Code" https://code.visualstudio.com/License
install_brave_browser
install_jetbrains_toolbox
install_nvidia
install_brother_printer
open_files
code_settings
change_settings
tweak_extension_settings
kde_settings
git_config
setup_bash
#Remove this script file
cd $DIRECTORY
rm $FILE
reboot_countdown

