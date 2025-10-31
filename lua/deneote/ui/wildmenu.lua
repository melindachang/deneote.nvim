---@module 'nui.menu'

local Component = require('deneote.ui.component')
local Menu = require('deneote.ui.menu')
local Prompt = require('deneote.ui.prompt')

---@class WildMenuComponentProps
---@field title? string
---@field items? string[]

---@class WildMenuComponent: Component, WildMenuComponentProps
---@field prompt PromptComponent
---@field menu MenuComponent
---@field state Signal<{ text: string }>
local M = Component:new()

---@type WildMenuComponent
M.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  title = '',
  items = {},
  box_options = { dir = 'col', size = { width = 40, height = 50 } },
  initial_state = {
    text = '',
  },
})

---@param instance WildMenuComponent
---@return WildMenuComponent
function M:init(instance)
  instance.prompt = Prompt:new({
    title = instance.title,
    box_options = { size = { width = '100%', height = 5 } },
  })

  instance.menu = Menu:new({
    items = instance.items,
    box_options = { grow = 1 },
    menu_options = {
      keymap = {
        submit = '<>', -- prevent default
      },
    },
  })

  -- override default
  instance.menu.nui:map('n', '<CR>', function()
    local buf = instance.menu.nui.bufnr or -1
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    local value = vim.api.nvim_get_current_line()

    instance.menu.state:next({ selected = { text = value } })
  end, { noremap = true })

  instance.menu:watch({
    next = function(v)
      local keyword = v.selected.text
      local current = instance.prompt.state:get_value().text
      instance.prompt.state:next({ text = current .. ',' .. keyword })
    end,
  })

  instance.prompt:watch({
    complete = function(v)
      instance.state:complete(v)
    end,
  })

  instance:add_child(instance.prompt)
  instance:add_child(instance.menu)

  return instance
end

return M
