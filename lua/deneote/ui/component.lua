---@module 'nui.popup'
---@module 'nui.layout'

---@alias NuiObject NuiPopup | NuiLayout

---@class Component
---@field state table
---@field mounted boolean
---@field parent? Component
---@field children Component[]
---@field nui? NuiObject
---@field events table<string, fun(...)[]>
---@field init? fun(self: Component, props: Component): Component
local M = {}

M.defaults = {
  state = {},
  mounted = false,
  parent = nil,
  children = {},
  nui = nil,
  events = {},
}

---@return Component
function M:new(props)
  local instance = vim.tbl_deep_extend('force', {}, self.defaults, props or {})

  if type(instance.nui) == 'function' then
    instance.nui = instance.nui()
  end

  setmetatable(instance, self)
  self.__index = self

  if self.init then
    instance = self:init(instance)
  end

  return instance
end

---@param partial table
function M:set_state(partial)
  self.state = vim.tbl_extend('force', self.state or {}, partial)
end

---@param event string
---@param callback fun(...)
function M:on(event, callback)
  self.events[event] = self.events[event] or {}
  table.insert(self.events[event], callback)
end

---@param event string
---@param ... any
function M:emit(event, ...)
  local lst = self.events[event]
  if lst then
    for _, cb in ipairs(lst) do
      cb(...)
    end
  end
end

---@param child Component
function M:add_child(child)
  self.children = self.children or {}
  table.insert(self.children, child)
end

---@param parent? Component
function M:mount(parent)
  self.parent = parent

  if self.nui and not self.mounted then
    self.nui:mount()
    self.mounted = true
  end

  for _, child in ipairs(self.children) do
    child:mount(self)
  end
end

function M:unmount()
  for _, child in ipairs(self.children) do
    child:unmount()
  end

  if self.nui and self.mounted then
    self.nui:unmount()
  end

  self.mounted = false
end

return M
