-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- =======
-- IMPORTS
-- =======

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local os = require("os")

-- =====================
-- USER CONFIG DIRECTORY (you should be there if you see this file)
-- =====================

local local_config_dir = "~/.config/awesome/"

-- ==============
-- ERROR HANDLING
-- ==============

if awesome.startup_errors then
    naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal(
        "debug::error", 
        function (err)
            if in_error then return end
            in_error = true

            naughty.notify({
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err) })
            in_error = false
        end
    )
end

-- =====
-- THEME
-- =====

beautiful.init(local_config_dir .. "themes/default/theme.lua")

-- ==================
-- CONFIG DEFINITIONS
-- ==================

local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "vim"
local editor_cmd = terminal .. " -e " .. editor

local modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}

local dmenu_mon = "0" -- Monitor number to display dmenu on
-- WARNING! You may need to install Ubuntu fonts if you're on a distro
-- other than Ubuntu
local dmenu_font = "UbuntuMono-R.ttf:size=14:antialias=true"
local dmenu_nb = beautiful.bg_normal -- Normal background color
local dmenu_nf = beautiful.fg_normal -- Normal foreground color
local dmenu_sb = beautiful.bg_focus -- Selected background color
local dmenu_sf = beautiful.fg_focus -- Selected foreground color
local amixer_step = "5%"
local brightnessctl_step = "5%"
local weather_location = "Kyiv" -- Put your city/location to get weather

-- ======================
-- COMMANDS FOR SHORTCUTS
-- ======================

local lock_screen = "i3lock -i /home/linetm/.config/awesome/themes/default/bg.png"

local run_dmenu = string.format(
    'dmenu_run -m %s -fn %s -nb "%s" -nf "%s" -sb "%s" -sf "%s"',
    dmenu_mon,
    dmenu_font,
    dmenu_nb,
    dmenu_nf,
    dmenu_sb,
    dmenu_sf
)

-- WARNING: Following 5 require PulseAudio and pactl
local up_volume = string.format(
    "pactl set-sink-volume @DEFAULT_SINK@ +%s",
    amixer_step
)

local down_volume = string.format(
    "pactl set-sink-volume @DEFAULT_SINK@ -%s",
    amixer_step
)

local mute_toggle = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
local get_mute = "pactl get-sink-mute @DEFAULT_SINK@ | awk -F ' ' '{print $2}'"
local get_volume = "pactl get-sink-volume @DEFAULT_SINK@ | head -1 | awk -F ' ' '{print $5}'"

-- WARNING: Following 4 require brightnessctl
local up_brightness = string.format("brightnessctl set %s+", brightnessctl_step)
local down_brightness = string.format("brightnessctl set %s-", brightnessctl_step)
local get_brightness = "brightnessctl get"


-- =================
-- UTILS FOR WIDGETS
-- =================

local function read_stat_file(file)
    local content = ""
    local f = io.open(file, "r")
    if f then
        io.input(f)
        content = io.read()
        io.close(f)
    end
    return content
end

local function get_audio_sink_mute()
    local outP = assert(io.popen(get_mute, "r"))
    local output = outP:read("l")
    outP:close()
    if output == "no" then
        return false
    else
        return true
    end
end

local function get_audio_sink_volume()
    local outP = assert(io.popen(get_volume, "r"))
    local output = outP:read("l")
    outP:close()
    return output
end

local function get_screen_brightness()
    local outP = assert(io.popen(get_brightness, "r"))
    local output = outP:read("l")
    outP:close()
    return output
end

local function get_weather()
    local outP = assert(io.popen("curl -s wttr.in/"..weather_location.."?format='%c%t'"))
    local output = outP:read("l")
    outP:close()

    return output
end

local function battery_capacity(batN) 
    return string.format("/sys/class/power_supply/BAT%d/capacity", batN)
end

local ac_connected = "/sys/class/power_supply/ACAD/online"

-- =====
-- WIBAR
-- =====

local function w_separator(id)
    return wibox.widget {
        {
            id      = tostring(id),
            text    = "   ",
            widget  = wibox.widget.textbox,
        },
        layout = wibox.layout.stack
    }
end

local w_layout = awful.widget.keyboardlayout()

local w_clock = wibox.widget.textclock("🕐 %a %b %d, %H:%M:%S ", 1)

local w_battery = wibox.widget {
    {
        id          = "batmon",
        text        = "...",
        widget      = wibox.widget.textbox,
    },
    layout = wibox.layout.stack,
    set_battery = function(self, val)
        local is_charging = read_stat_file(ac_connected)
        local emoji = "🔋"
        if is_charging == "1" then
            emoji = "🔌"
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
        self.batmon.text  = emoji.." "..tonumber(val).."%"
        self.batmon.value = tonumber(val)
    end,
}
gears.timer {
    timeout   = 1,
    call_now  = true,
    autostart = true,
    callback  = function()
        local cap = battery_capacity(1)
        local charge = read_stat_file(cap)
        w_battery.battery = charge
    end
}

local w_volume = wibox.widget {
    {
        id          = "volumemon",
        text        = "...",
        widget      = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    -- Would love a hint on how to do it not using the setter :/
    set_update = function(self, v)
        local is_muted = get_audio_sink_mute()
        local emoji = ""
        if is_muted then
            emoji = "🔇"
        else
            emoji = "🔊"
        end
        local volume = get_audio_sink_volume()
        self.volumemon.text = emoji.." "..volume
    end,
}
gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function ()
        w_volume.update = 1
    end
}

local w_brightness = wibox.widget {
    {
        id          = "brightnessmon",
        text        = "...",
        widget      = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    set_value = function(self, val)
        local val_num = tonumber(val)
        local percentage = math.floor(val_num / 255 * 100)
        self.brightnessmon.text = "🔅 "..percentage.."%"
    end
}
gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function () 
       local brightness = get_screen_brightness()
       w_brightness.value = brightness
    end
}

local w_weather = wibox.widget {
    {
        id          = "weathermon",
        text        = "...",
        widget      = wibox.widget.textbox
    },
    layout = wibox.layout.stack,
    set_value       = function(self, val)
        self.weathermon.text = val
    end
}
gears.timer {
    timer = 3600,
    call_now = true,
    autostart = true,
    callback = function ()
        local wttrin = get_weather()
        w_weather.value = wttrin
    end
}

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end

end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            w_separator(1),
            wibox.widget.systray(),
            w_separator(2),
            wibox.widget.textbox("⌨️"),
            w_layout,
            w_separator(3),
            w_weather,
            w_separator(4),
            w_battery,
            w_separator(5),
            w_volume,
            w_separator(6),
            w_brightness,
            w_separator(7),
            w_clock,
            s.mylayoutbox,
        },
    }
end)

-- ============
-- KEY BINDINGS
-- ============

-- Notes: the, here default, tiling mode uses DWM's master-stack layout.
-- The order of the windows is considered as:
-- Master -> stack top -> stack bottom.
-- So when referring to the order of the windows in tags - consider that
-- order. The letter strings also must be lowercase
local globalkeys = gears.table.join(

    awful.key(
        { modkey }, "s",
        hotkeys_popup.show_help,
        { description="Show help", group="awesome" }
    ),

    awful.key(
        { modkey }, "b",
        awful.tag.viewprev,
        { description = "View previous tag", group = "tag" }
    ),

    awful.key(
        { modkey }, "n",
        awful.tag.viewnext,
        { description = "View next tag", group = "tag" }
    ),

    awful.key(
        { modkey }, "Escape",
        awful.tag.history.restore,
        { description = "Go to last visited tag", group = "tag" }
    ),

    awful.key(
        { modkey }, "j",
        function () awful.client.focus.byidx(1) end,
        { description = "Focus next client in tag", group = "client" }
    ),

    awful.key(
        { modkey }, "k",
        function () awful.client.focus.byidx(-1) end,
        { description = "Focus prev client in tag", group = "client" }
    ),

    awful.key(
        { modkey }, "w",
        function () mymainmenu:show() end,
        { description = "Show main menu", group = "awesome" }
    ),

    awful.key(
        { modkey, "Shift" }, "j",
        function () awful.client.swap.byidx(1) end,
        { description = "Swap with next client in tag", group = "client" }
    ),

    awful.key(
        { modkey, "Shift" }, "k",
        function () awful.client.swap.byidx(-1) end,
        { description = "Swap with prev client in tag", group = "client" }
    ),

    awful.key(
        { modkey, }, "u",
        awful.client.urgent.jumpto,
        { description = "Jump to the client with urgent signal", group = "client" }
    ),

    awful.key(
        { modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "Focus the previously focused client", group = "client" }
    ),

    awful.key(
        { modkey }, "Return",
        function () awful.spawn(terminal) end,
        { description = "Open default terminal", group = "launcher" }
    ),

    awful.key(
        { modkey, "Control" }, "r",
        awesome.restart,
        { description = "Reload AwesomeWM", group = "awesome" }
    ),

    awful.key(
        { modkey, "Shift" }, "q",
        awesome.quit,
        { description = "Quit AwesomeWM session", group = "awesome" }
    ),

    awful.key(
        { modkey }, "l",
        function () awful.tag.incmwfact( 0.05) end,
        { description = "Increase master size by 0.05 of screen width", group = "layout" }
    ),

    awful.key(
        { modkey }, "h",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "Decrease master size by 0.05 of screen width", group = "layout" }
    ),

    awful.key(
        { modkey, "Shift" }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        { description = "Increase the number of master clients", group = "layout" }
    ),

    awful.key(
        { modkey, "Shift" }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        { description = "Decrease the number of master clients", group = "layout" }
    ),

    awful.key(
        { modkey, "Shift" }, "t",
        function ()
            local screen = awful.screen.focused()
            screen.mywibox.visible = not screen.mywibox.visible
        end,
        { description = "Toggle the visibility of status bar on current screen", group = "layout" }
    ),

    awful.key(
        { modkey, "Control" }, "h",
        function () awful.tag.incncol(1, nil, true) end,
        { description = "Increase the number of stack columns", group = "layout" }
    ),

    awful.key(
        { modkey, "Control" }, "l",
        function () awful.tag.incncol(-1, nil, true) end,
        { description = "Decrease the number of stack columns", group = "layout" }
    ),

    awful.key(
        { modkey }, "space",
        function () awful.layout.inc(1) end,
        { description = "Switch to next window mode", group = "layout" }
    ),

    awful.key(
        { modkey, "Shift" }, "space",
        function () awful.layout.inc(-1) end,
        { description = "Switch to prev window mode", group = "layout" }
    ),

    awful.key(
        {modkey, "Shift" }, "x",
        function () awful.util.spawn(lock_screen) end,
        { description = "Lock screen", group = "programs" }
    ),

    awful.key(
        { modkey }, "d",
        function () awful.spawn(run_dmenu) end,
        { description = "Open dmenu", group = "programs" }
    ),

    -- The following are media keys that have special mappings.
    -- For you it could be a separate key on the keyboard or the Fn-mappings. For those you can use xev to look up what
    -- key names these end up using, or set your own combination with `modkey`, "Ctrl", etc

    awful.key(
        {}, "XF86AudioMute",
        function () awful.spawn(mute_toggle) end,
        { description = "Toggle volume muting", group = "system" }
    ),

    awful.key(
        {}, "XF86AudioLowerVolume",
        function () awful.spawn(down_volume) end,
        { description = "Lower volume", group = "system" }
    ),

    awful.key(
        {}, "XF86AudioRaiseVolume",
        function () awful.spawn(up_volume) end,
        { description = "Raise volume", group = "system" }
    ),

    awful.key(
        {}, "XF86MonBrightnessDown",
        function () awful.spawn(down_brightness) end,
        { description = "Lower screen brightness", group = "system" }
    ),

    awful.key({}, "XF86MonBrightnessUp",
        function () awful.spawn(up_brightness) end,
        { description = "Raise screen brightness", group = "system" }
    )

    -- Note: not using prompt and menubar here, cuz these just look ugly, I'll better be off using
    -- dmenu or rovi.
    -- Also there also was a Lua interpreter prompt for... reasons? Not doing that shit either...
)

local clientkeys = gears.table.join(

    awful.key(
        { modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "Toggle fullscreen", group = "client" }
    ),

    awful.key(
        { modkey }, "q",
        function (c) c:kill() end,
        { description = "Close", group = "client" }
    ),

    awful.key(
        { modkey, "Control" }, "space",
        awful.client.floating.toggle,
        { description = "Toggle floating mode", group = "client" }
    ),

    awful.key(
        { modkey }, "z",
        function (c) c:swap(awful.client.getmaster()) end,
        { description = "Move to master", group = "client" }
    ),

    awful.key(
        { modkey }, "t",
        function (c) c.ontop = not c.ontop end,
        { description = "Toggle keeping over other clients (on top)", group = "client" }
    ),

    awful.key(
        { modkey, "Shift" }, "m",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "Minimize", group = "client" }
    ),

    awful.key(
        { modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "Toggle maximizing", group = "client"}
    )
)

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,

        awful.key(
            { modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "View tag #"..i, group = "tag" }
        ),

        awful.key(
            { modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "Add clients from tag #" .. i, group = "tag" }
        ),

        awful.key(
            { modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "Move focused client to tag #"..i, group = "tag" }
        ),

        awful.key(
            { modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "Toggle focused client on tag #" .. i, group = "tag" }
        )
    )
end

local clientbuttons = gears.table.join(
    awful.button(
        { }, 1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end
    ),
    awful.button(
        { modkey }, 1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.move(c)
        end
    ),
    awful.button(
        { modkey }, 3,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.resize(c)
        end
    )
)

root.keys(globalkeys)

-- =====
-- RULES
-- =====

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {

    -- All clients will match this rule.
    { rule = { },
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- List of clients that are forced to floating mode
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer",
        },
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    {
        rule_any = {
            type = { "normal" }
        }, 
        properties = { titlebars_enabled = false }
    },
    {
        rule_any = {
            type = { "dialog" }
        },
        properties = { titlebars_enabled = true }
    },
    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}

-- =======
-- SIGNALS
-- =======

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function (c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)

client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        {
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            {
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        {
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
