-- Command definitions
local _lock_screen = "i3lock -i /home/linetm/.config/awesome/themes/default/bg.png"
local _run_dmenu = 'dmenu_run -m %s -fn %s -nb "%s" -nf "%s" -sb "%s" -sf "%s"'
local _open_xdotool_bookmarks = 'grep -v "^#" /home/linetm/.local/share/util/bookmarks | dmenu -i -l 50 -m %s -fn %s -nb "%s" -nf "%s" -sb "%s" -sf "%s" | cut -d" " -f1'
local _xdotool_type = 'xdotool type %s'
local _get_mute = "pactl get-sink-mute @DEFAULT_SINK@ | awk -F ' ' '{print $2}'"
local _toggle_mute = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
local _get_volume = "pactl get-sink-volume @DEFAULT_SINK@ | head -1 | awk -F ' ' '{print $5}'"
local _up_volume = "pactl set-sink-volume @DEFAULT_SINK@ +%s"
local _down_volume = "pactl set-sink-volume @DEFAULT_SINK@ -%s"
local _brightness_up = "brightnessctl set %s+"
local _brightness_down = "brightnessctl set %s-"
local _get_brightness = "brightnessctl get"
local _get_weather = 'curl -s http://wttr.in/Kyiv?format="%c%t" | sed "s/ //g"'

local commands = {}

function commands.lock_screen()
   return _lock_screen
end

function commands.run_dmenu(mon, font, nb, nf, sb, sf)
    return string.format(_run_dmenu, mon, font, nb, nf, sb, sf)
end

function commands.open_bookmarks(mon, font, nb, nf, sb, sf)
    return string.format(_open_xdotool_bookmarks, mon, font, nb, nf, sb, sf)
end

function commands.type(s)
    return string.format(_xdotool_type, s)
end

-- WARNING: Following 5 require PulseAudio and pactl

function commands.get_mute()
    return _get_mute
end

function commands.toggle_mute()
    return _toggle_mute
end

function commands.get_volume()
    return _get_volume
end

function commands.up_volume(step)
    return string.format(_up_volume, step)
end

function commands.down_volume(step)
    return string.format(_down_volume, step)
end

-- WARNING: Following 3 require brightnessctl

function commands.up_brightness(step)
    return string.format(_brightness_up, step)
end

function commands.down_brightness(step)
    return string.format(_brightness_down, step)
end

function commands.get_brightness()
    return _get_brightness
end

function commands.get_weather()
    return _get_weather
end

return commands
