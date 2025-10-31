local Signal = require('deneote.ui.signal')
local Utils = require('deneote.utils')
local layout = require('nui.layout')
local box = layout.Box

---@class ComponentProps
---@field initial_state? table
---@field box_options? nui_layout_box_options

---@class Component: ComponentProps
---@field children? Component[]
---@field nui? NuiPopup
---@field state? Signal<table>
---@field init? fun(self: Component, instance: Component): Component
local M = {}

---@type Component
M.defaults = {
  box_options = {
    size = { height = '100%', width = '100%' },
  },
}

---@generic T: Component
---@param props? ComponentProps
---@return T
function M:new(props)
  props = props or {}

  local instance = vim.tbl_deep_extend('force', {}, self.defaults, props)
  instance.state = Signal:new(instance.initial_state or {})

  setmetatable(instance, self)
  self.__index = self

  instance:watch({
    next = function()
      instance:on_update()
    end,
  })

  if self.init then
    instance = self:init(instance)
  end

  return instance
end

---@param child Component
function M:add_child(child)
  self.children = self.children or {}
  table.insert(self.children, child)
end

---@return NuiLayout.Box
function M:render()
  if self.children then
    local components = Utils.map(self.children, function(child)
      return child:render()
    end)

    return box(components, self.box_options)
  end

  assert(self.nui, 'Composite component must have children')

  return box(self.nui, self.box_options)
end

---@param opts SignalSubscriber
function M:watch(opts)
  self.state:subscribe(opts)
end

---@param modify_fn fun(...): nil
function M:modify_buffer_content(modify_fn)
  vim.schedule(function()
    -- self:set_buffer_option('modifiable', true)
    modify_fn()
    -- self:set_buffer_option('modifiable', false)
  end)
end

---@param key string
---@param value any
function M:set_buffer_option(key, value)
  if self.nui then
    local buf = self.nui.bufnr or -1
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_set_option_value(key, value, { buf = self.nui.bufnr })
    end
  end
end

-- TODO: consider other lifecycle hooks
function M:on_update() end

return M
