local Component = require('deneote.ui.component')
local Utils = require('deneote.utils')
local menu = require('nui.menu')

---@class MenuComponentProps
---@field popup_opts nui_popup_options
---@field menu_opts nui_menu_options
---@field title string
---@field items string[]

---@class MenuComponent: Component, MenuComponentProps
---@field nui NuiMenu
---@field state { selected: '', filtered: string[] }
local Menu = Component:new()

---@type MenuComponent
Menu.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  popup_opts = {
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
  menu_opts = {},
  title = '',
  items = {},
  state = {
    selected = '',
    filtered = {},
  },
})

---@param instance MenuComponent
---@return MenuComponent
function Menu:init(instance)
  instance.nui = menu(
    instance.popup_opts,
    vim.tbl_extend('force', instance.menu_opts, {
      lines = Utils.map(instance.items, function(item)
        return menu.item(item)
      end),
      on_change = function(value)
        instance:set_state({ selected = value })
        instance:emit('change', value)
      end,
      on_submit = function(value)
        instance:unmount()
        instance:set_state({ selected = value })
        instance:emit('submit', value)
      end,
    })
  )

  if instance.title ~= '' then
    instance.nui.border:set_text('top', ' ' .. instance.title .. ' ')
  end

  return instance
end
