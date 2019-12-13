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

echo -e '\e[36mCopy the link address of the "Try again" button link from:\e[m' https://slack.com/downloads/instructions/ubuntu
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
done

# Update Files
print_good_output "Updating packages"

sudo apt update
sudo apt upgrade -y --allow-downgrades

# Remove unwanted packages
sudo apt autoremove -y
print_good_output "Removing unwanted packages"

sudo apt-get --purge remove firefox -y 

#Install Brave
print_good_output "Installing Brave Browser"

sudo apt install apt-transport-https curl -y
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser -y

#Install slack
print_good_output "Getting Slack"

wget "$SLACK"
sudo apt update
sudo dpkg -i ~/*/slack*.deb -y



#Install Spotify 
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

# Install git, redshift
print_good_output "Installing wanted packages"

sudo apt update
sudo apt install synaptic gnome-tweaks gnome-shell-extension-ubuntu-dock -y
rm slack*.deb

sudo apt-get update && sudo apt-get install redshift redshift-gtk scribus -y


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

else
print_error_output "BAD JETBRAINS CHECKSUM"
print_error_output "Jetbrains toolbox will not install."
fi

rm jetbrains*.tar.gz jetbrains*.sha256

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
sudo apt install system76-cuda-latest system76-cudnn-*.* -y
else
print_good_output "No NVIDIA drivers found"
fi

if [ $brother_printer = 'y' ]; then
wget "$BROTHER_DRIVER"
gunzip linux-brprinter-installer-*.*.*-*.gz
sudo bash linux-brprinter-installer-*.*.*-* $BROTHER_MODEL
rm linux-brprinter-installer* brscan*.deb cupswrapper*.deb mfc*.deb
fi

# #Install vscode
print_good_output "Installing VS Code"

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https -y
sudo apt-get update
sudo apt-get install code -y # or code-insiders


# Add redshift settings

echo '[redshift]
; Set the day and night screen temperatures
temp-day=4000
temp-night=4000

; Enable/Disable a smooth transition between day and night
; 0 will cause a direct change from day to night screen temperature.
; 1 will gradually increase or decrease the screen temperature
transition=1

; Set the screen brightness. Default is 1.0
;brightness=0.9
; It is also possible to use different settings for day and night since version 1.8.
;brightness-day=0.7
;brightness-night=0.4
; Set the screen gamma (for all colors, or each color channel individually)
gamma=0.9

;gamma=0.8:0.7:0.8
; Set the location-provider: 'geoclue', 'gnome-clock', 'manual'
; type 'redshift -l list' to see possible values
; The location provider settings are in a different section.
location-provider=manual

; Set the adjustment-method: 'randr', 'vidmode'
; type 'redshift -m list' to see all possible values
; 'randr' is the preferred method, 'vidmode' is an older API
; but works in some cases when 'randr' does not.
; The adjustment method settings are in a different section.
adjustment-method=randr

; Configuration of the location-provider:
; type 'redshift -l PROVIDER:help' to see the settings
; e.g. 'redshift -l manual:help'
[manual]
lat=43
lon=1

; Configuration of the adjustment-method
; type 'redshift -m METHOD:help' to see the settings
; ex: 'redshift -m randr:help'
; In this example, randr is configured to adjust screen 1.
; Note that the numbering starts from 0, so this is actually the second screen.
[randr]
screen=0' > ~/.config/redshift.conf

# Tweak Settings
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'previews'
git config --global credential.helper cache
git config --global credential.helper "cache --timeout=3600"



sudo apt-get update && sudo apt-get upgrade && sudo apt-get autoremove -y
sudo apt update && sudo apt upgrade && sudo apt autoremove -y

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

reboot
