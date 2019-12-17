# Introduction
This script was written to reduce the time to setup a new installation of Pop!_OS to my preferences.  This script helps automate some mundane tasks such as setting up the git config file and disabling telemetry from VS Code. 

# Running the script on a fresh install of Pop!_OS
To run this script:

1. Copy the script into the gedit text editor.
2. Save the script as pop.sh
3. Navigate to the directory of the script.  Change the permissions with the command `chmod u+x pop.sh`
4. Run the script with `./pop.sh`

# Packages installed
* apt-transport-https 
* Brave browser
* Brother printer drivers
* curl 
* deja-dup 
* gconf2 
* git-lfs 
* gnome-shell-extension-ubuntu-dock
* gnome-tweaks 
* gparted
* Jetbrains Toolbox
* libappindicator1 
* libdbusmenu-gtk4 
* plasma-applet-redshift-control
* redshift 
* scribus 
* slack-desktop
* spotify-client
* synaptic 
* tensorman 
* thunderbird 
* xdotool

If requested:
* kde-plasma-desktop

If the machine has a Nvidia Graphics Card:
* system76-cuda-latest
* system76-cudnn-\*.\*

# Packages Removed
* firefox 
* geary
* gedit 
* gnome-weather 

If KDE Desktop is installed:
* akregator
* dragonplayer
* gwenview
* imagemagick
* juk
* kate
* kcalc
* kmail
* kopete


# Settings and configurations
The script changes following settings and configurations on the system.

## gitconfig
* Sets --global user.name
* Sets --global user.emal
* Sets credential.helper timout to 3600 seconds

## bash
* Uses [Bash-it](https://github.com/Bash-it/bash-it) color scheme.
* Sets the Bash-it theme to "powerline-plain"
* Sets the cursor a blinking ibeam

## VS Code
* Sets autosave to "afterDelay"
* Disables crash reporter
* Disables telemetry
* Sets color scheme to "Monokai"

## Gnome
* Creates a view desktop command
* Minimizes open windows by clicking the applications favorite icon
* Auto hides the dock to the bottem center of the screen
* Removes the trash icon from favorites
* Removes mounts icon from favorites
* Enables night light to run at all times
* Sets night light a temperature of 4000
* Changes the theme to "Pop-dark"
* Disables animations
* Shows the battery percentage
* Enables removal of trash and temp files after 30 days.
* Creates a desktop view
* Changes touch pad setting to "areas" click method.
* Sets custom enabled-extensions
* Sets the favorite bar to display Brave, Thunderbird, Spotify, Jetbrains Toolbox, VS Code, Files, and Show desktop icons.

## KDE
* Sets theme to "Breeze Dark"
