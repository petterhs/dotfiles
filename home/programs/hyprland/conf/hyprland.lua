-- Migrated from hyprland.conf for Hyprland >= 0.55 (Lua config)

------------------
---- MONITORS ----
------------------

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

hl.monitor({
  output = "DP-3",
  mode = "1920x1200",
  position = "-1920x0",
  scale = 1,
})

hl.monitor({
  output = "DP-5",
  mode = "1920x1080",
  position = "0x0",
  scale = 1,
})

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  input = {
    kb_layout = "us,no",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:alt_shift_toggle,caps:escape",
    kb_rules = "",
    follow_mouse = 1,
    mouse_refocus = false,
    natural_scroll = false,
    force_no_accel = false,
    numlock_by_default = true,
    touchpad = {
      natural_scroll = true,
    },
  },

  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 4,
    col = {
      active_border = "0xFFB4A1DB",
      inactive_border = "0xFF343A40",
    },
  },

  decoration = {
    rounding = 8,
    active_opacity = 1.0,
    inactive_opacity = 0.9,
    fullscreen_opacity = 1.0,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      ignore_opacity = false,
    },
  },

  animations = {
    enabled = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

hl.animation({ leaf = "windows", enabled = true, speed = 8, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "default" })

-----------------------
---- WINDOW RULES -----
-----------------------

hl.window_rule({
  name = "foot-float",
  match = { class = "foot-float" },
  float = true,
})

hl.window_rule({
  name = "floating-utils",
  match = { class = "^(yad|nm-connection-editor|pavucontrol)$" },
  float = true,
})

hl.window_rule({
  name = "floating-qt-utils",
  match = { class = "^(xfce-polkit|kvantummanager|qt5ct)$" },
  float = true,
})

hl.window_rule({
  name = "floating-viewers",
  match = { class = "^(feh|imv|Gpicview|Gimp|nomacs)$" },
  float = true,
})

hl.window_rule({
  name = "floating-vm",
  match = { class = "^(VirtualBox Manager|qemu|Qemu-system-x86_64)$" },
  float = true,
})

hl.window_rule({
  name = "xfce4-appfinder",
  match = { class = "xfce4-appfinder" },
  float = true,
})

hl.window_rule({
  name = "foot-full",
  match = { class = "foot-full" },
  float = true,
  move = { 0, 0 },
  size = "100% 100%",
})

hl.window_rule({
  name = "wlogout",
  match = { class = "wlogout" },
  float = true,
  move = { 0, 0 },
  size = "100% 100%",
  animation = "slide",
})

hl.window_rule({
  name = "thunar",
  match = { class = "thunar" },
  float = true,
  size = "30% 50%",
})

hl.window_rule({
  name = "pavucontrol",
  match = { class = "org.pulseaudio.pavucontrol" },
  float = true,
  size = "30% 50%",
})

hl.window_rule({
  name = "scratchpad-teams",
  match = { class = "^(teams-for-linux)$" },
  float = true,
  workspace = "special silent",
})

hl.window_rule({
  name = "scratchpad-term",
  match = { class = "^(alacritty-dropterm)$" },
  float = true,
  workspace = "special silent",
})

-----------------------
---- KEYBINDINGS ------
-----------------------

local term = "alacritty"
local app_launcher = os.getenv("HOME") .. "/.config/hypr/scripts/menu.sh"
local sesh_launcher = os.getenv("HOME") .. "/.config/hypr/scripts/sesh-menu.sh"
local volume = os.getenv("HOME") .. "/.config/hypr/scripts/volume"
local backlight = os.getenv("HOME") .. "/.config/hypr/scripts/brightness"
local lockscreen = os.getenv("HOME") .. "/.config/hypr/scripts/lockscreen.sh"
local wlogout = os.getenv("HOME") .. "/.config/hypr/scripts/wlogout.sh"
local colorpicker = os.getenv("HOME") .. "/.config/hypr/scripts/colorpicker.sh"

-- Terminal / launchers
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term))
hl.bind("SUPER + T", hl.dsp.exec_cmd("bash " .. sesh_launcher))
hl.bind("SUPER + D", hl.dsp.exec_cmd("bash " .. app_launcher))

-- Hyprland
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.window.pseudo())

-- Misc
hl.bind("SUPER + N", hl.dsp.exec_cmd("nm-connection-editor"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("bash " .. colorpicker))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("bash " .. lockscreen))
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd("bash " .. wlogout))

-- Scratchpads (pypr)
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("pypr toggle teams"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("pypr toggle term"))

-- Mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Function keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("bash " .. backlight .. " --inc"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("bash " .. backlight .. " --dec"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("bash " .. volume .. " --inc"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("bash " .. volume .. " --dec"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("bash " .. volume .. " --toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("bash " .. volume .. " --toggle-mic"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mpc next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mpc prev"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mpc toggle"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("mpc stop"), { locked = true })

-- Screenshots
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots -- imv"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots -- imv"))
hl.bind(
  "CTRL + Print",
  hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=sway flameshot gui --raw -p ~/Pictures/Screenshots | wl-copy")
)

-- Focus
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- Move windows
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

-- Move workspace between monitors
hl.bind("SUPER + SHIFT + left", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.workspace.move({ monitor = "r" }))

-- Resize
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

-- Workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
  hl.exec_cmd("bash " .. os.getenv("HOME") .. "/.config/hypr/scripts/start.sh")
  hl.exec_cmd("hyprland-per-window-layout")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("pypr")
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
end)
