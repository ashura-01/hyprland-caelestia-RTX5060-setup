-- Hyprland Lua config (Caelestia shell)
-- https://wiki.hypr.land/configuring/

----------------------
---- Window rule -----
----------------------
hl.window_rule({ match = { class = "org.kde.dolphin" }, opacity = "0.85 override 0.85 override" })








------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"


-------------------
---- AUTOSTART ----
-------------------

-- Caelestia replaces waybar, mako, hyprpaper and the launcher
hl.on("hyprland.start", function ()
hl.exec_cmd("caelestia shell -d")
hl.exec_cmd("systemctl --user start hyprpolkitagent")
hl.exec_cmd("sh -c 'sleep 4 && hyprctl setcursor breeze_cursors 24'")
hl.exec_cmd("clipse -listen")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
hl.env("HYPRCURSOR_SIZE", "24")

hl.exec_cmd("hyprctl setcursor breeze_cursors 24")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("QT_QPA_PLATFORMTHEME", "kde")


-----------------------
---- LOOK AND FEEL ----
-----------------------

local function scheme_colour(key, alpha, fallback)
local f = io.open(os.getenv("HOME") .. "/.local/state/caelestia/scheme.json", "r")
if not f then return fallback end
    local txt = f:read("*a")
    f:close()
    local hex = txt:match('"' .. key .. '"%s*:%s*"#?(%x%x%x%x%x%x)"')
    if not hex then return fallback end
        return "rgba(" .. hex .. alpha .. ")"
        end

        local active_border   = scheme_colour("primary",        "ff", "rgba(e9d5ffff)")
        local inactive_border = scheme_colour("outlineVariant", "66", "rgba(3b2f5c66)")

        hl.config({
            general = {
                gaps_in  = 3,
                gaps_out = 8,

                border_size = 1,

                col = {
                    active_border   = active_border,
                    inactive_border = inactive_border,
                },

                resize_on_border = false,
                allow_tearing    = false,
                layout           = "dwindle",
            },

            decoration = {
                rounding       = 10,
                rounding_power = 2,

                active_opacity   = 1.0,
                inactive_opacity = 1.0,

                shadow = {
                    enabled      = true,
                    range        = 2,
                    render_power = 1,
                    color        = 0xee1a1a1a,
                },

                blur = {
                    enabled  = true,
                  size     = 2,
                  passes   = 1,
                  vibrancy = 0.1696,
                },
            },

            animations = {
                enabled = true,  -- ← CHANGED: was false, needed for slide transition
            },
        })

        hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
        hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
        hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
        hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
        hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

        hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

        hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
        hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
        hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
        hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
        hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
        hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
        hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
        hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
        hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
        hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
        hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
        hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
        hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3,    bezier = "easeOutQuint", style = "slide" })   -- ← CHANGED
        hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 3,    bezier = "easeOutQuint", style = "slide" })   -- ← CHANGED
        hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 3,    bezier = "easeOutQuint", style = "slide" })   -- ← CHANGED
        hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

        hl.config({
            dwindle = {
                preserve_split = true,
            },
        })

        hl.config({
            master = {
                new_status = "master",
            },
        })

        hl.config({
            scrolling = {
                fullscreen_on_one_column = true,
            },
        })


        ----------------
        ----  MISC  ----
        ----------------

        hl.config({
            misc = {
                force_default_wallpaper = 0,
                    disable_hyprland_logo   = true,
            },
        })

        hl.config({
            cursor = {
                no_hardware_cursors = true,
            },
        })


        ----------------
        ---- LAYERS ----
        ----------------

        hl.config({
            layers = {
                allow_new_top_layers_over_existing_fullscreen = true,
            },
        })

        hl.layer_rule({
            name  = "fuzzel-slide",
            match = { namespace = "launcher" },
            animation = "slide bottom",
        })


        ---------------
        ---- INPUT ----
        ---------------

        hl.config({
            input = {
                kb_layout  = "us",
                kb_variant = "",
                kb_model   = "",
                kb_options = "",
                kb_rules   = "",

                follow_mouse = 1,
                sensitivity  = 0,

                touchpad = {
                    natural_scroll = false,
                },
            },
        })

        hl.gesture({
            fingers   = 3,
            direction = "horizontal",
            action    = "workspace",
        })


        ---------------------
        ---- KEYBINDINGS ----
        ---------------------

        local mainMod = "SUPER"

        hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd("kitty"))
        hl.bind(mainMod .. " + C",         hl.dsp.window.close())
        hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd("dolphin"))
        hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu --config ~/.config/fuzzel/clipboard.ini | cliphist decode | wl-copy"))
        hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen())
        hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
        hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
        hl.bind(mainMod .. " + M",         hl.dsp.exit())

        hl.bind(mainMod .. " + R",         hl.dsp.global("caelestia:launcher"))
        hl.bind(mainMod .. " + SPACE",     hl.dsp.global("caelestia:launcher"))
        hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.global("caelestia:session"))
        hl.bind(mainMod .. " + N",         hl.dsp.global("caelestia:sidebar"))
        hl.bind(mainMod .. " + TAB",       hl.dsp.global("caelestia:showall"))
        hl.bind(mainMod .. " + L",         hl.dsp.global("caelestia:lock"))
        hl.bind(mainMod .. " + SHIFT + N", hl.dsp.global("caelestia:clearNotifs"))
        hl.bind("Print",                   hl.dsp.global("caelestia:screenshot"))
        hl.bind("SHIFT + Print",           hl.dsp.global("caelestia:screenshotFreeze"))

        hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
        hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
        hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
        hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
        hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
        hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
        hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
        hl.dsp.window.swap({ direction = "left" })

        for i = 1, 10 do
            local key = i % 10
            hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
            end

            hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
            hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

            hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
            hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

            hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
            hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
            hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
            hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

            hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
            hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
            hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
            hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


            --------------------------------
            ---- WINDOWS AND WORKSPACES ----
            --------------------------------
            hl.window_rule({
                name  = "caido-fix",
                match = { class = "Caido" },
                tile  = true,
                no_blur = true,
                decorate = false,
            })
            hl.window_rule({
                name  = "no-blur-kitty",
                match = { class = "kitty" },
                no_blur = true,
            })

            hl.window_rule({
                name  = "suppress-maximize-events",
                match = { class = ".*" },
                suppress_event = "maximize",
            })

            hl.window_rule({
                name  = "fix-xwayland-drags",
                match = {
                    class      = "^$",
                    title      = "^$",
                    xwayland   = true,
                    float      = true,
                    fullscreen = false,
                    pin        = false,
                },
                no_focus = true,
            })

            hl.window_rule({
                name  = "move-hyprland-run",
                match = { class = "hyprland-run" },
                move  = "20 monitor_h-120",
                float = true,
            })
