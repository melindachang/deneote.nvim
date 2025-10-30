local Component = require('deneote.ui.component')
local Utils = require('deneote.utils')
local menu = require('nui.menu')

---@class MenuComponentProps: ComponentProps
---@field popup_options? nui_popup_options
---@field menu_options? nui_menu_options
---@field title? string
---@field items? string[]

---@class MenuComponent: Component, MenuComponentProps
---@field nui NuiMenu
---@field _state Signal<{ selected: '', filtered: string[] }>
local M = Component:new()

---@type MenuComponent
M.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  popup_options = {
    zindex = 100,
    position = '50%',
    relative = 'editor',
    size = {
      width = 30,
      height = 5,
    },
    border = {
      padding = { 0, 1, 0, 1 },
      style = 'rounded',
      text = {
        top_align = 'left',
      },
    },
    win_options = {
      winblend = 7,
      winhighlight = 'FloatTitle:Title,FloatBorder:Normal,NormalFloat:Normal',
    },
  },
  menu_options = {},
  title = '',
  items = {},
  initial_state = {
    selected = '',
    filtered = {},
  },
})

---@param instance MenuComponent
---@return MenuComponent
function M:init(instance)
  instance.nui = menu(
    instance.popup_options,
    vim.tbl_extend('force', instance.menu_options, {
      lines = Utils.map(instance.items, function(item)
        return menu.item(item)
      end),
      on_submit = function(value)
        instance._state:complete({ selected = value })
      end,
    })
  )

  instance._state:next({
    selected = instance.items[1],
    filtered = instance.items,
  })

  if instance.title ~= '' then
    instance.nui.border:set_text('top', ' ' .. instance.title .. ' ')
  end

  return instance
end

return M
