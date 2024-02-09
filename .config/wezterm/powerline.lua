local LEFT_ARROW = utf8.char(0xe0b3)
local RIGHT_ARROW = utf8.char(0xe0b1)
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

local Alignment = { LEFT = {}, RIGHT = {} }

local M = { Alignment = Alignment }

function M.render(opts)
  local cells = opts['cells']
  local alignment = opts['alignment']
  local edge_bg_color = opts['edge_bg_color']

  local elements = {}
  assert(alignment == Alignment.LEFT or alignment == Alignment.RIGHT)

  for index = 1, #cells do
    local cell = cells[index]

    local bg_color = cell['bg_color']
    local fg_color = cell['fg_color']
    local subcells = cell['subcells']

    if alignment == Alignment.RIGHT then
      if edge_bg_color then
        table.insert(elements, { Background = { Color = edge_bg_color } })
      end
      table.insert(elements, { Foreground = { Color = bg_color } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end

    table.insert(elements, { Background = { Color = bg_color } })
    table.insert(elements, { Foreground = { Color = fg_color } })

    for subcell_index = 1, #subcells do
      local subcell = subcells[subcell_index]
      if subcell_index ~= 1 then
        if alignment == Alignment.RIGHT then
          table.insert(elements, { Text = LEFT_ARROW })
        else
          table.insert(elements, { Text = RIGHT_ARROW })
        end
      end
      table.insert(elements, { Text = ' ' .. subcell .. ' ' })
    end

    if alignment == Alignment.LEFT then
      if index == #cells then
        if edge_bg_color then
          table.insert(elements, { Background = { Color = edge_bg_color } })
        else
          table.insert(elements, 'ResetAttributes')
        end
      else
        table.insert(elements, { Background = { Color = cells[index + 1]['bg_color'] } })
      end
      table.insert(elements, { Foreground = { Color = bg_color } })
      table.insert(elements, { Text = SOLID_RIGHT_ARROW })
    end
  end

  return elements
end

return M
