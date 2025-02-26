local wezterm = require 'wezterm'
local powerline = require 'powerline'
local onedark = require 'onedark'

local M = {}

M.colors = {
  background = onedark.black,

  active_tab = {
    fg_color = onedark.white,
    bg_color = onedark.visual_grey,
  },

  inactive_tab = {
    fg_color = onedark.white,
    bg_color = onedark.black,
  },

  inactive_tab_hover = {
    fg_color = onedark.white,
    bg_color = onedark.comment_grey,
  },
}

M.colors.new_tab = M.colors.inactive_tab
M.colors.new_tab_hover = M.colors.inactive_tab_hover

M.style = {
  new_tab = wezterm.format(powerline.render {
    cells = {
      {
        fg_color = M.colors.background,
        bg_color = M.colors.background,
        subcells = {},
      },
      {
        fg_color = M.colors.new_tab.fg_color,
        bg_color = M.colors.new_tab.bg_color,
        subcells = { '+' },
      },
    },
    alignment = powerline.Alignment.LEFT,
    edge_bg_color = M.colors.background,
  }),

  new_tab_hover = wezterm.format(powerline.render {
    cells = {
      {
        fg_color = M.colors.background,
        bg_color = M.colors.background,
        subcells = {},
      },
      {
        fg_color = M.colors.new_tab_hover.fg_color,
        bg_color = M.colors.new_tab_hover.bg_color,
        subcells = { '+' },
      },
    },
    alignment = powerline.Alignment.LEFT,
    edge_bg_color = M.colors.background,
  }),
}

function M.format_tab_title(tab, tabs, panes, window_config, hover, max_width)
  local _, _ = tabs, panes

  local tab_index = tostring(tab.tab_index + 1)

  local title = tab.tab_title
  if not (title and #title > 0) then
    title = tab.active_pane.title
  end
  title = string.sub(title, 1, max_width - 7 - #tab_index)

  local fg_color
  local bg_color
  if hover then
    fg_color = window_config.colors.tab_bar.inactive_tab_hover.fg_color
    bg_color = window_config.colors.tab_bar.inactive_tab_hover.bg_color
  elseif tab.is_active then
    fg_color = window_config.colors.tab_bar.active_tab.fg_color
    bg_color = window_config.colors.tab_bar.active_tab.bg_color
  else
    fg_color = window_config.colors.tab_bar.inactive_tab.fg_color
    bg_color = window_config.colors.tab_bar.inactive_tab.bg_color
  end

  local cells = {
    {
      fg_color = window_config.colors.tab_bar.background,
      bg_color = window_config.colors.tab_bar.background,
      subcells = {},
    },
    {
      fg_color = fg_color,
      bg_color = bg_color,
      subcells = { tab_index, title },
    },
  }

  return powerline.render {
    cells = cells,
    alignment = powerline.Alignment.LEFT,
    edge_bg_color = window_config.colors.tab_bar.background,
  }
end

function M.update_status(window, pane)
  local hostname = ''
  -- local cwd = ''

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    if type(cwd_uri) == 'userdata' then
      -- Running on a newer version of wezterm and we have
      -- a URL object here, making this simple!

      -- cwd = cwd_uri.file_path
      hostname = cwd_uri.host or wezterm.hostname()
    else
      -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
      -- which doesn't have the Url object
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:find '/'
      if slash then
        hostname = cwd_uri:sub(1, slash - 1)
        -- and extract the cwd from the uri, decoding %-encoding
        -- cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
        --   return string.char(tonumber(hex, 16))
        -- end)
      end
    end

    -- Remove the domain name portion of the hostname
    local dot = hostname:find '[.]'
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == '' then
      hostname = wezterm.hostname()
    end
  end

  local left_status = powerline.render {
    cells = {
      {
        fg_color = onedark.black,
        bg_color = onedark.red,
        subcells = { window:active_key_table() },
      },
      {
        fg_color = onedark.black,
        bg_color = onedark.yellow,
        subcells = { pane:get_domain_name() },
      },
      {
        fg_color = onedark.black,
        bg_color = onedark.green,
        subcells = { hostname },
      },
    },
    alignment = powerline.Alignment.LEFT,
  }
  window:set_left_status(wezterm.format(left_status))

  local time_of_day = wezterm.strftime '%H:%M:%S'
  local date = wezterm.strftime '%a %Y-%m-%d'

  local battery_infos = {}
  for _, battery_info in ipairs(wezterm.battery_info()) do
    local formatted = string.format('%.0f%%', battery_info.state_of_charge * 100)
    table.insert(battery_infos, formatted)
  end

  local right_status = powerline.render {
    cells = {
      {
        fg_color = onedark.white,
        bg_color = onedark.black,
        subcells = { time_of_day, date },
      },
      {
        fg_color = onedark.white,
        bg_color = onedark.visual_grey,
        subcells = battery_infos,
      },
      {
        fg_color = onedark.black,
        bg_color = onedark.blue,
        subcells = { window:active_workspace() },
      },
    },
    alignment = powerline.Alignment.RIGHT,
  }
  window:set_right_status(wezterm.format(right_status))
end

function M.init(config)
  if config.colors == nil then
    config.colors = {}
  end
  config.colors.tab_bar = M.colors

  config.tab_bar_style = M.style
  config.tab_bar_at_bottom = true
  config.tab_max_width = 25
  config.use_fancy_tab_bar = false
  wezterm.on('update-status', M.update_status)
  wezterm.on('format-tab-title', M.format_tab_title)
end

return M
