-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


config.font = wezterm.font_with_fallback {
  'IosevkaTerm Nerd Font',
  'Noto Color Emoji',
}
config.font_size = 16
config.color_scheme = 'catppuccin-mocha'
config.enable_wayland = false
config.enable_kitty_graphics = true

config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

config.window_background_opacity = 0.7
return config
