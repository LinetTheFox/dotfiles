local awful = require("awful")
local gears = require("gears")

local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local commands = require("commands")
local config = require("config")
local utils = require("utils")


local shortcuts = {}

-- Global shortcuts
shortcuts.global_keys = gears.table.join(

    awful.key(
        { config.modkey }, "s",
        hotkeys_popup.show_help,
        { description="Show help", group="awesome" }
    ),

    awful.key(
        { config.modkey }, "b",
        awful.tag.viewprev,
        { description = "View previous tag", group = "tag" }
    ),

    awful.key(
        { config.modkey }, "n",
        awful.tag.viewnext,
        { description = "View next tag", group = "tag" }
    ),

    awful.key(
        { config.modkey }, "Escape",
        awful.tag.history.restore,
        { description = "Go to last visited tag", group = "tag" }
    ),

    awful.key(
        { config.modkey }, "j",
        function () awful.client.focus.byidx(1) end,
        { description = "Focus next client in tag", group = "client" }
    ),

    awful.key(
        { config.modkey }, "k",
        function () awful.client.focus.byidx(-1) end,
        { description = "Focus prev client in tag", group = "client" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "j",
        function () awful.client.swap.byidx(1) end,
        { description = "Swap with next client in tag", group = "client" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "k",
        function () awful.client.swap.byidx(-1) end,
        { description = "Swap with prev client in tag", group = "client" }
    ),

    awful.key(
        { config.modkey, }, "u",
        awful.client.urgent.jumpto,
        { description = "Jump to the client with urgent signal", group = "client" }
    ),

    awful.key(
        { config.modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "Focus the previously focused client", group = "client" }
    ),

    awful.key(
        { config.modkey }, "Return",
        function () awful.spawn(config.terminal) end,
        { description = "Open default terminal", group = "launcher" }
    ),

    awful.key(
        { config.modkey, "Control" }, "r",
        awesome.restart,
        { description = "Reload AwesomeWM", group = "awesome" }
    ),


    awful.key(
        { config.modkey, "Shift" }, "q",
        awesome.quit,
        { description = "Quit AwesomeWM session", group = "awesome" }
    ),

    awful.key(
        { config.modkey }, "l",
        function () awful.tag.incmwfact( 0.05) end,
        { description = "Increase master size by 0.05 of screen width", group = "layout" }
    ),

    awful.key(
        { config.modkey }, "h",
        function () awful.tag.incmwfact(-0.05) end,
        { description = "Decrease master size by 0.05 of screen width", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        { description = "Increase the number of master clients", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        { description = "Decrease the number of master clients", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "t",
        function ()
            local screen = awful.screen.focused()
            screen.mywibox.visible = not screen.mywibox.visible
        end,
        { description = "Toggle the visibility of status bar on current screen", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Control" }, "h",
        function () awful.tag.incncol(1, nil, true) end,
        { description = "Increase the number of stack columns", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Control" }, "l",
        function () awful.tag.incncol(-1, nil, true) end,
        { description = "Decrease the number of stack columns", group = "layout" }
    ),

    awful.key(
        { config.modkey }, "space",
        function () awful.layout.inc(1) end,
        { description = "Switch to next window mode", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "space",
        function () awful.layout.inc(-1) end,
        { description = "Switch to prev window mode", group = "layout" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "x",
        function () awful.util.spawn(commands.lock_screen()) end,
        { description = "Lock screen", group = "programs" }
    ),

    awful.key(
        { config.modkey }, "d",
        function ()
            awful.spawn(commands.run_dmenu(config.dmenu_mon, config.dmenu_font, config.dmenu_nb, config.dmenu_nf, config.dmenu_sb, config.dmenu_sf))
        end,
        { description = "Open dmenu", group = "programs" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "b",
        function ()
            awful.spawn(utils.get_and_paste_bookmark(config.dmenu_mon, config.dmenu_font, config.dmenu_nb, config.dmenu_nf, config.dmenu_sb, config.dmenu_sf))
        end,
        { description = "Open dmenu with bookmarks to paste", group = "programs" }
    ),

    -- The following are media keys that have special mappings.
    -- For you it could be a separate key on the keyboard or the Fn+Something. For those you can use xev to look up what
    -- key names these end up using, or set your own combination with `modkey`, "Ctrl", etc

    awful.key(
        {}, "XF86AudioMute",
        function () awful.spawn(commands.toggle_mute()) end,
        { description = "Toggle volume muting", group = "system" }
    ),

    awful.key(
        {}, "XF86AudioLowerVolume",
        function () awful.spawn(commands.down_volume(config.amixer_step)) end,
        { description = "Lower volume", group = "system" }
    ),

    awful.key(
        {}, "XF86AudioRaiseVolume",
        function () awful.spawn(commands.up_volume(config.amixer_step)) end,
        { description = "Raise volume", group = "system" }
    ),

    awful.key(
        {}, "XF86MonBrightnessDown",
        function () awful.spawn(commands.down_brightness(config.brightnessctl_step)) end,
        { description = "Lower screen brightness", group = "system" }
    ),

    awful.key({}, "XF86MonBrightnessUp",
        function () awful.spawn(commands.up_brightness(config.brightnessctl_step)) end,
        { description = "Raise screen brightness", group = "system" }
    )
)

-- Client shortcuts
shortcuts.client_keys = gears.table.join(

    awful.key(
        { config.modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "Toggle fullscreen", group = "client" }
    ),

    awful.key(
        { config.modkey }, "q",
        function (c) c:kill() end,
        { description = "Close", group = "client" }
    ),

    awful.key(
        { config.modkey, "Control" }, "space",
        awful.client.floating.toggle,
        { description = "Toggle floating mode", group = "client" }
    ),

    awful.key(
        { config.modkey }, "z",
        function (c) c:swap(awful.client.getmaster()) end,
        { description = "Move to master", group = "client" }
    ),

    awful.key(
        { config.modkey }, "t",
        function (c) c.ontop = not c.ontop end,
        { description = "Toggle keeping over other clients (on top)", group = "client" }
    ),

    awful.key(
        { config.modkey, "Shift" }, "m",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "Minimize", group = "client" }
    ),

    awful.key(
        { config.modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "Toggle maximizing", group = "client"}
    )
)

-- Shortcuts interacting with tags (`i` represents each of 9 tags)
for i = 1, 9 do
    shortcuts.global_keys = gears.table.join(
        shortcuts.global_keys,

        awful.key(
            { config.modkey }, "#" .. i + 9,
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
            { config.modkey, "Control" }, "#" .. i + 9,
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
            { config.modkey, "Shift" }, "#" .. i + 9,
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
            { config.modkey, "Control", "Shift" }, "#" .. i + 9,
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

-- Client interactions with mouse
shortcuts.client_buttons = gears.table.join(

    awful.button(
        { }, 1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
        end
    ),

    awful.button(
        { config.modkey }, 1,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.move(c)
        end
    ),

    awful.button(
        { config.modkey }, 3,
        function (c)
            c:emit_signal("request::activate", "mouse_click", {raise = true})
            awful.mouse.client.resize(c)
        end
    )
)

-- Clicks on tag buttons in top bar
shortcuts.taglist_buttons = gears.table.join(

    awful.button(
        { }, 1,
        function(t)
            t:view_only()
        end
    ),

    awful.button(
        { config.modkey }, 1,
        function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end
    ),

    awful.button(
        { }, 3,
        awful.tag.viewtoggle
    ),

    awful.button(
        { config.modkey }, 3,
        function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end
    ),

    awful.button(
        { }, 4,
        function(t)
            awful.tag.viewnext(t.screen)
        end
    ),

    awful.button(
        { }, 5,
        function(t)
            awful.tag.viewprev(t.screen)
        end
    )
)

shortcuts.tasklist_buttons = gears.table.join(

    awful.button(
        { }, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal(
                    "request::activate",
                    "tasklist",
                    { raise = true }
                )
            end
        end
    ),

    awful.button(
        { }, 3,
        function()
            awful.menu.client_list({ theme = { width = 250 } })
        end
    ),

    awful.button(
        { }, 4,
        function ()
            awful.client.focus.byidx(1)
        end
    ),

    awful.button(
        { }, 5,
        function ()
            awful.client.focus.byidx(-1)
        end
    )
)

-- Interactions of layoutbox with mouse
shortcuts.layoutbox_buttons = gears.table.join(
    awful.button(
        { }, 1,
        function ()
            awful.layout.inc(1)
        end
    ),
    awful.button(
        { }, 3,
        function ()
            awful.layout.inc(-1)
        end
    ),
    -- For the extra side keys - that are available on some gaming mice
    awful.button(
        { }, 4,
        function ()
            awful.layout.inc(1)
        end
    ),
    awful.button(
        { }, 5,
        function ()
            awful.layout.inc(-1)
        end
    )
)

return shortcuts