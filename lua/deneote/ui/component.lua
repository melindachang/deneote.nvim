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
---@field _state? Signal<table>
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
  instance._state = Signal:new(instance.initial_state or {})

  setmetatable(instance, self)
  self.__index = self

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

---@param modify_fn fun(...): nil
function M:modify_buffer_content(modify_fn)
  vim.schedule(function()
    modify_fn()
  end)
end

---@param opts SignalSubscriber
function M:watch(opts)
  self._state:subscribe(opts)
end

return M
