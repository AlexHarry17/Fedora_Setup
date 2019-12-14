#!/bin/bash
DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FILE=$(basename $BASH_SOURCE) 
cd ~/.config
mkdir autostart
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

brother_printer_setup () {
brother_printer=''
while true;
do
print_no_format "Do you want to set up a Brother Printer? [n/Y]"
read brother_printer
if [[ $brother_printer = 'y' || -z $brother_printer ]]; then
print_no_format_link 'Vist the following link. Search for your model.  Choose the "Driver Install Tool".  Read and agree to the license. Copy the link address of "If your download does not start automatically, please click here.":' 'https://support.brother.com/g/b/productsearch.aspx?c=us&lang=en&content=dl'
print_no_format 'Paste link address here:'
read BROTHER_DRIVER
print_no_format 'Enter your printer model:'
read BROTHER_MODEL
break
fi
if [ $brother_printer = 'n' ]; then
break
else
print_error_output "Enter 'y' for yes or 'n' for no"
fi
done
}

initial_package_upgrade() {
sudo apt update && sudo apt upgrade -y --allow-downgrades && sudo apt autoremove -y
}

remove_package() {

sudo apt --purge remove -y
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

print_no_format_link 'Copy the link address of the "Try again" button link from:' https://slack.com/downloads/instructions/ubuntu
print_no_format 'Paste link address here:'
read SLACK

print_good_output "Github Setup"
print_no_format "What is your name?:"
read GITHUB_USER_NAME

print_no_format "What is your email?:"
read GITHUB_USER_EMAIL

# Ask for brother printer install
print_good_output "Printer Setup"
brother_printer_setup

# Update Files
print_good_output "Updating packages"

initial_package_upgrade

# Remove unwanted packages
print_good_output "Removing unwanted packages"

sudo apt --purge remove gedit gnome-weather firefox geary -y 

# #Install Brave
# print_good_output "Installing Brave Browser"

# sudo apt install apt-transport-https curl -y
# curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
# echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# sudo apt update
# sudo apt install brave-browser -y


# #Install Spotify 
# curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
# echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
# sudo apt-get update && sudo apt-get install spotify-client -y

# # Install git, redshift
# print_good_output "Installing wanted packages"

# sudo apt update
# sudo apt install xdotool git-lfs deja-dup synaptic gconf2 libdbusmenu-gtk4 scribus libappindicator1 thunderbird gnome-tweaks gnome-shell-extension-ubuntu-dock -y


# mkdir ~/Desktop/Programs/

# PROGRAM_FOLDER='Desktop/Programs/'

# print_good_output "Installing Jetbrains Toolbox"

# # Get Jetbrains toolbox
# wget "$JETBRAINS_TOOLBOX" -P $PROGRAM_FOLDER
# wget "$JETBRAINS_TOOLBOX_CHECKSUM" -P $PROGRAM_FOLDER

# cd $PROGRAM_FOLDER

# # Verify Jetbrains toolbox checksum
# if [[ "$(sha256sum -c jetbrains*.sha256)" == *"OK" ]]; then
# print_good_output "Jetbrains checksum OK"
# tar -xvf jetbrains*.tar.gz

# else
# print_error_output "BAD JETBRAINS CHECKSUM"
# print_error_output "Jetbrains toolbox will not install."
# fi

# rm jetbrains*.tar.gz jetbrains*.sha256

# # Setup git user
# git config --global user.name "$GITHUB_USER_NAME"
# git config --global user.email "$GITHUB_USER_EMAIL"
# git config --global color.ui auto
# git config --global color.branch auto
# git config --global color.status auto

# # Install NVIDIA Drivers
# echo -e '\e[36m----------Checking for NVIDIA Graphics ----------\e[m
# '
# if [[ $(lspci | grep -E "VGA|3D") == *"NVIDIA"* ]]; then
# print_good_output "NVIDIA drivers Found"
# sudo apt install system76-cuda-latest system76-cudnn-*.* -y
# else
# print_good_output "No NVIDIA drivers found"
# fi

# if [ $brother_printer = 'y' ]; then
# wget "$BROTHER_DRIVER"
# gunzip linux-brprinter-installer-*.*.*-*.gz
# sudo bash linux-brprinter-installer-*.*.*-* $BROTHER_MODEL
# rm linux-brprinter-installer* brscan*.deb cupswrapper*.deb mfc*.deb
# fi

# # #Install vscode

# #Error with download, using snap
# sudo apt update
# sudo apt install snapd
# print_good_output "Installing VS Code"

# sudo snap install code --classic

# # Install slack
# sudo apt update
# print_good_output "Installing Slack"
# cd
# wget "$SLACK"
# sudo dpkg -i slack*.deb
# rm slack*.deb


# print_good_output "Installing Bash Colors"
# git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
# ~/.bash_it/install.sh <<EOF
# N
# EOF

# cd $PROGRAM_FOLDER/jetbrains*
# ./jetbrains-tool*
# sleep 2
# xdotool windowminimize $(xdotool getactivewindow)
# cd
# snap run code
# sleep 4
# xdotool windowminimize $(xdotool getactivewindow)
# sudo apt autoremove -y
# # Reboot system
# for ((countdown=30; countdown>=1; countdown--))
# do
# echo -n -e "\r\e[31m---------- Installer Finished - Rebooting in $countdown seconds ----------\e[m"
#     sleep 1
# done
# echo''
# #VSCode Settings
# echo '{
#     "files.autoSave": "afterDelay",
#     "telemetry.enableCrashReporter": false,
#     "telemetry.enableTelemetry": false,
#     "workbench.colorTheme": "Monokai"
# }' >> ~/.config/Code/User/settings.json

# echo '[Desktop Entry]
# Type=Application
# Name=Show Desktop
# Icon=desktop
# Exec=xdotool key --clearmodifiers Super+d' >> ~/.local/share/applications/show-desktop.desktop

# # Remove jetbrians-toolbox autostart
# rm ~/.config/autostart/jetbrains*.desktop
# # Tweak Settings
# gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
# gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size
# gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
# gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
# gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
# gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
# gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
# gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
# gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
# gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
# gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 04.0
# gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 03.98333333
# gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
# gsettings set org.gnome.desktop.interface gtk-theme Pop-dark
# gsettings set org.gnome.desktop.interface enable-animations false
# gsettings set org.gnome.desktop.interface show-battery-percentage true
# gsettings set org.gnome.desktop.notifications show-in-lock-screen true
# gsettings set org.gnome.system.location enabled false
# gsettings set org.gnome.desktop.privacy remove-old-trash-files true
# gsettings set org.gnome.desktop.privacy remove-old-temp-files true
# gsettings set org.gnome.desktop.peripherals.touchpad click-method areas
# gsettings set org.gnome.shell enabled-extensions "['alt-tab-raise-first-window@system76.com', 'always-show-workspaces@system76.com', 'batteryiconfix@kylecorry31.github.io', 'donotdisturb@kylecorry31.github.io', 'pop-shop-details@system76.com', 'pop-suspend-button@system76.com', 'system76-power@system76.com', 'ubuntu-dock@ubuntu.com']"
# gsettings set org.gnome.shell favorite-apps "['brave-browser.desktop', 'thunderbird.desktop', 'spotify.desktop', 'slack.desktop', 'jetbrains-toolbox.desktop', 'code_code.desktop', 'org.gnome.Nautilus.desktop', 'show-desktop.desktop']"
# git config --global credential.helper cache
# git config --global credential.helper "cache --timeout=3600"
# sed -i -e "s/export BASH_IT_THEME='bobby'/export BASH_IT_THEME='powerline-plain'/g" ~/.bashrc

# echo "
# # Add blinking ibeam cursor
# echo -ne '\e[5 q'
# " >> ~/.bashrc

# cd $DIRECTORY
# rm $FILE

# reboot
