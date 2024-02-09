local wezterm = require 'wezterm'
local tab_bar = require 'tab_bar'

local config = wezterm.config_builder()

config.color_scheme = 'Colors (base16)'
config.font = wezterm.font 'MesloLGM Nerd Font'

config.initial_cols = 200
config.initial_rows = 48

config.force_reverse_video_cursor = true

wezterm.on('gui-attached', function(_)
  local workspace = wezterm.mux.get_active_workspace()
  for _, window in ipairs(wezterm.mux.all_windows()) do
    if window:get_workspace() == workspace then
      window:gui_window():set_position(0, 0)
    end
  end
end)

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.unix_domains = {
  {
    name = 'local-machine'
  },
}
config.default_domain = 'local-machine'

tab_bar.init(config)

local local_machine_config_exists, local_machin_config = pcall(require, 'local_machine')
if local_machine_config_exists then
  local_machin_config.init(config)
end

return config
