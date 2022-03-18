#! /usr/bin/env bash
# since vncserver is running as a daemon, we're creating a foreground process uppon vncserver for supervisord.

# Reason: vnc server fails to start via supervisor process:
# spawnerr: unknown error making dispatchers for 'vncserver': ENOENT
# alternative: /usr/bin/Xvnc $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION -Log *:stderr:100
# e.g.: /usr/bin/Xvnc :1 -auth $HOME/.Xauthority -depth 24 -desktop VNC -fp /usr/share/fonts/X11/misc,/usr/share/fonts/X11/Type1 -geometry 1600x900 -pn -rfbauth $HOME/.vnc/passwd -rfbport 5901 -rfbwait 30000
# $HOME/.vnc/xstartup
# vncserver uses Xvnc, all Xvnc options can be used (e.g. for logging)
# https://wiki.archlinux.org/index.php/TigerVNC

set -eu

# Set default values for vnc settings if not provided
VNC_PW=${VNC_PW:-"vncpassword"}
VNC_RESOLUTION=${VNC_RESOLUTION:-"1600x900"}
VNC_COL_DEPTH=${VNC_COL_DEPTH:-"24"}

mkdir -p /home/sdwot/.vnc
touch /home/sdwot/.vnc/passwd

# Set password:
echo "$VNC_PW" | vncpasswd -f >> /home/sdwot/.vnc/passwd
chmod 600 /home/sdwot/.vnc/passwd

config_file=/home/sdwot/.vnc/config
touch $config_file
printf "geometry=$VNC_RESOLUTION\ndepth=$VNC_COL_DEPTH\ndesktop=Desktop-GUI\nsession=xfce" > /home/sdwot/.vnc/config
command="/usr/libexec/vncserver $DISPLAY"
sleep 1
$command &> "/home/sdwot/.vnc/vnc.log" &
sleep 5


exit 1000 # exit unexpected


