local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local shortcuts = require("shortcuts")
local widgets = require("widgets")
local rules = require("rules")

-- Handling errors
-- Will show a notification with lua stacktrace if any error occurs
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
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
                text = tostring(err)
            })
            in_error = false
        end
    )
end

awful.layout.layouts = {
    -- Only setting the floating and tiling (master-stack) window layouts
    -- Dunno why you would need anything else :P
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}

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

-- Re-set wallpaper when a screen's geometry changes
-- (e.g. changing screen to a different resolution with xrandr)
screen.connect_signal("property::geometry", set_wallpaper)

-- Adding top bar and wallpaper for each tag
awful.screen.connect_for_each_screen(
    function(s)
        set_wallpaper(s)

        -- Setting tags - you can put any fancy characters here if you want
        awful.tag(
            { "一", "二", "三", "四", "五", "六", "七", "八", "九" },
            s, awful.layout.layouts[1]
        )

        -- List of "tabs" for each window with its icon and title
        s.mypromptbox = awful.widget.prompt()

        -- Icon that shows current window layout mode (e.g. tiling)
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(shortcuts.layoutbox_buttons)

        -- Taglist
        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = shortcuts.taglist_buttons
        }

        -- Status panel
        s.mytasklist = awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = shortcuts.tasklist_buttons
        }

        -- Create and position the bar
        s.mywibox = awful.wibar({
            position = "top",
            screen = s
        })

        -- Add widgets to the bar
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
                widgets.separator,
                wibox.widget.systray(),
                widgets.separator,
                widgets.keyboard,
                widgets.separator,
                widgets.weather,
                widgets.separator,
                widgets.battery,
                widgets.separator,
                widgets.volume,
                widgets.separator,
                widgets.brightness,
                widgets.separator,
                widgets.clock,
                s.mylayoutbox,
            },
        }
    end
)

-- Apply global shortcuts
root.keys(shortcuts.global_keys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = rules

-- Signal function to execute when a new client appears.
client.connect_signal(
    "manage",
    function (c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end
        if awesome.startup
          and not c.size_hints.user_position
          and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
    end
)

-- Update the border colors depending on whether the client is focused or not
client.connect_signal(
    "focus",
    function (c)
        c.border_color = beautiful.border_focus
    end
)

client.connect_signal(
    "unfocus",
    function (c)
        c.border_color = beautiful.border_normal
    end
)

-- Build top bars for clients that have them
client.connect_signal(
    "request::titlebars",
    function(c)
        local buttons = gears.table.join(
            -- Enable dragging while holding Mouse1
            awful.button( { }, 1,
                function()
                    c:emit_signal(
                        "request::activate", "titlebar",
                        { raise = true }
                    )
                    awful.mouse.client.move(c)
                end
            ),
            -- Enable resizing when holding Mouse3
            awful.button( { }, 3,
                function()
                    c:emit_signal(
                        "request::activate", "titlebar",
                        { raise = true }
                    )
                    awful.mouse.client.resize(c)
                end
            )
        )
        -- Build titlebar
        awful.titlebar(c) : setup {
            -- Client icon
            {
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            -- Title
            {
                {
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            -- Buttons
            {
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
        }
    end
)
