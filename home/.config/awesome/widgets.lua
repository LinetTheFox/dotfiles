local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local utils = require("utils")
local files = require("files")

-- Prerequisites
local keyboard_layout = awful.widget.keyboardlayout()
keyboard_layout.widget.font = "Envy Code R 11"
local keyboard_emoji = wibox.widget {
    {
        id = "keyboard_emoji",
        text = "⌨",
        font = "Envy Code R 11",
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.stack
}

local widgets = {}

widgets.keyboard = wibox.widget {
    keyboard_emoji,
    keyboard_layout,
    layout = wibox.layout.fixed.horizontal,
}

-- Apparently you can do HTML here :)
widgets.clock = wibox.widget.textclock("<span font=\"Envy Code R 11\">🕐 %a %d %b, %H:%M:%S </span>", 1)

widgets.brightness = wibox.widget {
    {
        id = "brightnessmon",
        text = "...",
        font = "Envy Code R 11",
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    set_value = function(self, val)
        local emoji = " "
        local val_num = tonumber(val)
        local percentage = math.floor(val_num / 255 * 100)
        if percentage < 50 then
            emoji = "🔅"
        else
            emoji = "🔆"
        end
        self.brightnessmon.text = emoji .. percentage .. "%"
    end
}

widgets.battery = wibox.widget {
    {
        id = "batmon",
        text = "...",
        font = "Envy Code R 11",
        widget = wibox.widget.textbox,
    },
    layout = wibox.layout.stack,
    set_battery = function(self, val)
        local is_charging = utils.read_stat_file(files.ac_connected())
        local emoji = "🔋"
        if is_charging == "1" then
            emoji = "⚡️"
        elseif tonumber(val) < 15 then
            emoji = "🪫"
            naughty.notify({
                title = "Warning",
                text = "Battery low!",
                height = 100,
                width = 500,
                preset = naughty.config.presets.critical,
                timeout = 1
            })
        end
        self.batmon.text = emoji .. tonumber(val) .. "%"
        self.batmon.value = tonumber(val)
    end,
}

widgets.volume = wibox.widget {
    {
        id          = "volumemon",
        text        = "...",
        font = "Envy Code R 11",
        widget      = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    -- Would love a hint on how to do it not using the setter :/
    set_update = function(self, _)
        local is_muted = utils.get_audio_sink_mute()
        local emoji = " "
        local volume = utils.get_audio_sink_volume()
        if (volume == nil) then
            volume = "0"
        end
        if is_muted then
            emoji = "🔇"
        else
            if volume == nil then
                emoji = " "
            elseif tonumber(volume:sub(1, -2)) < 33 then
                emoji = "🔈"
            elseif tonumber(volume:sub(1, -2)) < 66 then
                emoji = "🔉"
            else
                emoji = "🔊"
            end
        end
        self.volumemon.text = emoji .. volume
    end,
}

widgets.weather = wibox.widget {
    {
        id      = "weathermon",
        text    = "🌞🌚",
        font    = "Envy Code R 11",
        widget  = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    set_wttr = function(self, val)
        self.weathermon.text = val
    end
}

widgets.separator = wibox.widget {
    {
        text    = "  •  ",
        widget  = wibox.widget.textbox,
    },
    layout = wibox.layout.stack
}

gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        -- brightness
        local brightness_value = utils.get_screen_brightness()
        widgets.brightness.value = brightness_value
        -- battery
        local cap = files.battery_capacity(1)
        local charge = utils.read_stat_file(cap)
        widgets.battery.battery = charge
        -- volume
        widgets.volume.update = nil -- Just calling the method, don't mind nil
    end
}

gears.timer {
    timeout = 3600,
    call_now = true,
    autostart = true,
    callback = function()
        local weather_val = utils.get_weather()
        if weather_val ~= nil and weather_val ~= "" then
            widgets.weather.wttr = weather_val
        end
    end
}

return widgets