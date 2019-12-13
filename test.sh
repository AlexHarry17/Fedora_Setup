#!/bin/bash
echo '[Desktop Entry]
Type=Application
Exec=redshift-gtk && disown
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Redshift
Name=Redshift
Comment[en_US]=Starts up redshift
Comment=Starts up redshift' > ~/.config/autostart/redshift-gtk.desktop
