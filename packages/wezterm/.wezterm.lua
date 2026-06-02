local wezterm = require('wezterm')

local config = wezterm.config_builder()

config.initial_cols = 160
config.initial_rows = 50
config.enable_kitty_keyboard = true

return config
