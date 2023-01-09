local config = {}

config.dmenu_mon = "0" -- Monitor number to display dmenu on
-- WARNING! You may need to install Ubuntu fonts if you're on a distro
-- other than Ubuntu
config.dmenu_font = "UbuntuMono-R.ttf:size=14:antialias=true"
config.dmenu_nb = "#1E0027" -- Normal background dmenu color
config.dmenu_nf = "#AAAAAA" -- Normal foreground dmenu color
config.dmenu_sb = "#260133" -- Selected background dmenu color
config.dmenu_sf = "#FFFFFF" -- Selected foreground dmenu color
config.amixer_step = "5%"
config.brightnessctl_step = "5%"

config.modkey = "Mod4"
config.terminal = "alacritty"
config.editor = os.getenv("EDITOR") or "nvim"

return config