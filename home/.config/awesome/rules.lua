local awful = require("awful")
local beautiful = require("beautiful")

local local_config_dir = "~/.config/awesome/"
-- Grabs the local theme
beautiful.init(local_config_dir .. "themes/default/theme.lua")

local shortcuts = require("shortcuts")

local rules = {
    {
        -- Applying base rules for all clients
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = shortcuts.client_keys,
            buttons = shortcuts.client_buttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Forcing particular clients to use floating mode
    {
        rule_any = {
            instance = {
                "DTA",      -- Firefox addon DownThemAll.
                "copyq",    -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Security measure, to prevent fingerprinting by screen size
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "intellij-splash-screen", -- Splash is a small dialog and looks ugly when tiled
            },
            name = {
                "Event Tester",  -- xev.
                "splash",
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true
        }
    },

    -- Removing top bars from all windows
    {
        rule_any = {
            type = {
                "normal"
            }
        },
        properties = {
            titlebars_enabled = false
        }
    },

    -- But keeping those on dialogs - can be useful for e.g. GIMP.
    -- Can be specified more precisely to remove them where not needed,
    -- but keeping like this for now
    {
        rule_any = {
            type = {
                "dialog"
            }
        },
        properties = {
            titlebars_enabled = true
        }
    },
}

return rules