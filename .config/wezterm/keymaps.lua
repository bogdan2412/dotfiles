local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

local PaneAction = { MOVE = {}, RESIZE = {}, SWAP = {} }
local PaneDirection = { LEFT = {}, RIGHT = {}, DOWN = {}, UP = {} }

local nvim_pane_action_key = function(pane_action, pane_direction)
  local key
  local action_direction
  if pane_direction == PaneDirection.LEFT then
    key = 'h'
    action_direction = 'Left'
  elseif pane_direction == PaneDirection.RIGHT then
    key = 'l'
    action_direction = 'Right'
  elseif pane_direction == PaneDirection.DOWN then
    key = 'j'
    action_direction = 'Down'
  else
    assert(pane_direction == PaneDirection.UP)
    key = 'k'
    action_direction = 'Up'
  end

  local mods
  if pane_action == PaneAction.MOVE then
    mods = 'CTRL'
  elseif pane_action == PaneAction.RESIZE then
    mods = 'CTRL|ALT'
  else
    assert(pane_action == PaneAction.SWAP)
    mods = 'ALT'
  end

  return {
    key = key,
    mods = mods,
    action = wezterm.action_callback(function(window, pane)
      local is_vim = pane:get_user_vars().IS_NVIM == 'true'
      local is_tmux = pane:get_user_vars().IS_TMUX == 'true'
      local action
      if is_vim or is_tmux then
        action = act.SendKey { key = key, mods = mods }
      else
        if pane_action == PaneAction.MOVE then
          action = act.ActivatePaneDirection(action_direction)
        elseif pane_action == PaneAction.RESIZE then
          action = act.AdjustPaneSize { action_direction, 2 };
        else
          assert(pane_action == PaneAction.SWAP)

          local success, result = pcall(function()
            return act.SwapActivePaneDirection { direction = action_direction, keep_focus = true };
          end)

          if success then
            action = result
          end
        end
      end
      if action ~= nil then
        window:perform_action(action, pane)
      end
    end)
  }
end

local function nvim_pane_action_all_directions(action)
  return {
    nvim_pane_action_key(action, PaneDirection.LEFT),
    nvim_pane_action_key(action, PaneDirection.RIGHT),
    nvim_pane_action_key(action, PaneDirection.DOWN),
    nvim_pane_action_key(action, PaneDirection.UP),
  }
end

local function standard_keymaps(args)
  local key = args.key
  local shift_key = args.shift_key
  local action = args.action

  return {
    { key = key,       mods = 'SUPER',      action = action },
    { key = key,       mods = 'SHIFT|CTRL', action = action },
    { key = shift_key, mods = 'SHIFT|CTRL', action = action },
    { key = shift_key, mods = 'CTRL',       action = action },
  }
end

local function flatten_keymap_group_array(input)
  local keys = {}
  for _, keymap_group in ipairs(input) do
    for _, keymap in ipairs(keymap_group) do
      table.insert(keys, keymap)
    end
  end
  return keys
end

M.keys = flatten_keymap_group_array {
  standard_keymaps { key = 'w', shift_key = 'W', action = act.CloseCurrentTab { confirm = true } },
  standard_keymaps { key = 'q', shift_key = 'Q', action = act.QuitApplication },
  standard_keymaps { key = 'h', shift_key = 'H', action = act.HideApplication },
  standard_keymaps { key = 'm', shift_key = 'M', action = act.Hide },

  standard_keymaps { key = 'r', shift_key = 'R', action = act.ReloadConfiguration },
  standard_keymaps { key = 'l', shift_key = 'L', action = act.ShowDebugOverlay },

  standard_keymaps { key = 'c', shift_key = 'C', action = act.CopyTo 'Clipboard' },
  standard_keymaps { key = 'v', shift_key = 'V', action = act.PasteFrom 'Clipboard' },
  {
    { key = 'Copy',  mods = 'NONE', action = act.CopyTo 'Clipboard' },
    { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
  },

  standard_keymaps { key = '=', shift_key = '+', action = act.IncreaseFontSize },
  standard_keymaps { key = '-', shift_key = '_', action = act.DecreaseFontSize },
  standard_keymaps { key = '0', shift_key = ')', action = act.ResetFontSize },

  standard_keymaps {
    key = 'u',
    shift_key = 'U',
    action = act.CharSelect { copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' }
  },

  standard_keymaps { key = 'n', shift_key = 'N', action = act.SpawnWindow },

  {
    { key = 't',        mods = 'SUPER',       action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 't',        mods = 'CTRL',        action = act.SpawnTab 'CurrentPaneDomain' },

    { key = ']',        mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
    { key = '}',        mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(1) },
    { key = '}',        mods = 'SUPER',       action = act.ActivateTabRelative(1) },
    { key = 'Tab',      mods = 'CTRL',        action = act.ActivateTabRelative(1) },
    { key = 'PageDown', mods = 'CTRL',        action = act.ActivateTabRelative(1) },

    { key = '[',        mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
    { key = '{',        mods = 'SHIFT|SUPER', action = act.ActivateTabRelative(-1) },
    { key = '{',        mods = 'SUPER',       action = act.ActivateTabRelative(-1) },
    { key = 'Tab',      mods = 'SHIFT|CTRL',  action = act.ActivateTabRelative(-1) },
    { key = 'PageUp',   mods = 'CTRL',        action = act.ActivateTabRelative(-1) },

    { key = '.',        mods = 'SUPER',       action = act.MoveTabRelative(1) },
    { key = 'PageDown', mods = 'SHIFT|CTRL',  action = act.MoveTabRelative(1) },

    { key = ',',        mods = 'SUPER',       action = act.MoveTabRelative(-1) },
    { key = 'PageUp',   mods = 'SHIFT|CTRL',  action = act.MoveTabRelative(-1) },

    { key = '1',        mods = 'SUPER',       action = act.ActivateTab(0) },
    { key = '1',        mods = 'CTRL',        action = act.ActivateTab(0) },
    { key = '2',        mods = 'SUPER',       action = act.ActivateTab(1) },
    { key = '2',        mods = 'CTRL',        action = act.ActivateTab(1) },
    { key = '3',        mods = 'SUPER',       action = act.ActivateTab(2) },
    { key = '3',        mods = 'CTRL',        action = act.ActivateTab(2) },
    { key = '4',        mods = 'SUPER',       action = act.ActivateTab(3) },
    { key = '4',        mods = 'CTRL',        action = act.ActivateTab(3) },
    { key = '5',        mods = 'SUPER',       action = act.ActivateTab(4) },
    { key = '5',        mods = 'CTRL',        action = act.ActivateTab(4) },
    { key = '6',        mods = 'SUPER',       action = act.ActivateTab(5) },
    { key = '6',        mods = 'CTRL',        action = act.ActivateTab(5) },
    { key = '7',        mods = 'SUPER',       action = act.ActivateTab(6) },
    { key = '7',        mods = 'CTRL',        action = act.ActivateTab(6) },
    { key = '8',        mods = 'SUPER',       action = act.ActivateTab(7) },
    { key = '8',        mods = 'CTRL',        action = act.ActivateTab(7) },
    { key = '9',        mods = 'SUPER',       action = act.ActivateTab(-1) },
    { key = '9',        mods = 'CTRL',        action = act.ActivateTab(-1) },
  },

  nvim_pane_action_all_directions(PaneAction.MOVE),
  nvim_pane_action_all_directions(PaneAction.RESIZE),
  nvim_pane_action_all_directions(PaneAction.SWAP),

  standard_keymaps { key = 'z', shift_key = 'Z', action = act.TogglePaneZoomState },

  standard_keymaps {
    key = 'k',
    shift_key = 'K',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    }
  },

  standard_keymaps { key = 'f', shift_key = 'F', action = act.Search 'CurrentSelectionOrEmptyString' },
  standard_keymaps { key = 'x', shift_key = 'X', action = act.ActivateCopyMode },
  standard_keymaps { key = 'p', shift_key = 'P', action = act.ActivateCommandPalette },

  {
    { key = 'Enter',      mods = 'ALT',        action = act.ToggleFullScreen },

    { key = 'PageDown',   mods = 'SHIFT',      action = act.ScrollByPage(1) },
    { key = 'PageUp',     mods = 'SHIFT',      action = act.ScrollByPage(-1) },

    { key = 'DownArrow',  mods = 'SHIFT',      action = act.ScrollByLine(1) },
    { key = 'UpArrow',    mods = 'SHIFT',      action = act.ScrollByLine(-1) },

    { key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },
  },

  {
    {
      key = 'w',
      mods = 'CTRL',
      action = act.ActivateKeyTable {
        name = "leader_key",
        timeout_milliseconds = 1000,
        one_shot = true,
        until_unknown = true,
        prevent_fallback = true
      }
    },
  },
}

local function with_optional_ctrl(args)
  local key = args.key
  local action = args.action

  return {
    { key = key, action = action },
    { key = key, action = action, mods = 'CTRL' },
  }
end

M.leader_key_table = flatten_keymap_group_array {
  with_optional_ctrl {
    key = '\\',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  with_optional_ctrl {
    key = '-',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  with_optional_ctrl {
    key = 'd',
    action = act.DetachDomain 'CurrentPaneDomain',
  },

  with_optional_ctrl {
    key = 'c',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { Color = require('onedark').blue } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line ~= nil then
          if line ~= '' then
            window:perform_action(act.SwitchToWorkspace { name = line }, pane)
          else
            window:perform_action(act.SwitchToWorkspace {}, pane)
          end
        end
      end),
    },
  },
  with_optional_ctrl { key = 'n', action = act.SwitchWorkspaceRelative(1) },
  with_optional_ctrl { key = 'p', action = act.SwitchWorkspaceRelative(-1) },
  with_optional_ctrl { key = 'l', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },

  with_optional_ctrl {
    key = 'r',
    action = act.ActivateKeyTable { name = 'raw_input', one_shot = false }
  },

  {
    {
      key = 'w',
      mods = 'CTRL',
      action = act.SendKey { key = 'w', mods = 'CTRL' },
    }
  },
}

function M.init(config)
  config.disable_default_key_bindings = true

  local raw_input_table = {
    { key = 'Escape', mods = '', action = 'PopKeyTable' },
  }
  for _, item in ipairs(M.keys) do
    table.insert(raw_input_table, {
      key = item.key,
      mods = item.mods,
      action = act.SendKey { key = item.key, mods = item.mods }
    })
  end

  config.keys = M.keys
  config.key_tables = {
    leader_key = M.leader_key_table,
    raw_input = raw_input_table
  }

  config.mouse_bindings = {
    -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'SHIFT',
      action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'SHIFT|ALT',
      action = act.CompleteSelection 'PrimarySelection',
    },

    -- and make CTRL-Click open hyperlinks
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
  }
end

return M
