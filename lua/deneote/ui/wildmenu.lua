local Component = require('deneote.ui.component')
local Menu = require('deneote.ui.menu')
local Prompt = require('deneote.ui.prompt')

---@class WildMenuComponentProps
---@field title? string
---@field items? string[]

---@class WildMenuComponent: Component, WildMenuComponentProps
---@field prompt PromptComponent
---@field menu MenuComponent
---@field _state Signal<{ text: string }>
local M = Component:new()

---@type WildMenuComponent
M.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  title = '',
  items = {},
  box_options = { dir = 'col', size = { width = 40, height = 50 } },
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
  })

  -- TODO: wire events

  -- Set logical children
  instance:add_child(instance.prompt)
  instance:add_child(instance.menu)

  return instance
end

return M
