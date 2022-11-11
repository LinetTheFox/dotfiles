
# Running slstatus to display the stats in DWM bar
slstatus &

# Hiding mouse cursor if it hasn't moved in 3 seconds
unclutter --idle 3 &

# Setting up the configs for X applications
xrdb ~/.Xresources &

# Setting ru and us layouts and making caps toggle between them
setxkbmap pl,ru -option grp:caps_toggle &

# Adding key shortcuts
xbindkeys &

# Starting xcompmgr
xcompmgr &

# Adding the fonts paths for Xorg
xset +fp /usr/share/fonts/noto/

# Running AwesomeWM
exec /usr/bin/awesome
