
# Running slstatus to display the stats in DWM bar
slstatus &

# Hiding mouse cursor if it hasn't moved in 3 seconds
unclutter --idle 3 &

# Setting up the configs for X applications
xrdb ~/.Xresources &

# Setting ru and us layouts and making caps toggle between them
setxkbmap us,ru -option grp:caps_toggle &

# Adding key shortcuts
xbindkeys &

# Locking the screen after ten minutes
xautolock -time 10 -corners "-000" -locker slock &

# Starting xcompmgr
xcompmgr &

# Setting the wallpaper
feh --bg-fill ${HOME}/.local/wallpaper/sisu.jpg &

# Running DWM
exec /usr/local/bin/dwm

