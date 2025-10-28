---@module 'nui.popup'
---@module 'nui.layout'

---@alias NuiObject NuiPopup | NuiLayout

---@class ComponentProps User-facing props
---@field visible? boolean
---@field children? Component[]
---@field parent? Component
---@field nui? NuiObject | fun(...): NuiObject
---@field nui_opts? nui_popup_options

---@class ComponentInternals: ComponentProps
---@field mounted boolean
---@field mounts_children boolean
---@field nui? NuiObject

---@class Component: ComponentInternals Output shape
---@field init_hook? fun(self: Component, props: Component): Component Exposed for subclassses to mutate new prop table
---@field mount fun(self: Component, parent?: Component)
---@field unmount fun(self: Component)
---@field new fun(self: Component, props?: ComponentProps): Component
local M = {}

---@type ComponentInternals
M.defaults = {
  visible = true,
  children = nil,
  parent = nil,
  nui = nil,
  nui_opts = nil,

  mounted = false,
  mounts_children = false,
}

---@param props ComponentProps
---@return Component
function M:new(props)
  props = vim.tbl_deep_extend('force', {}, self.defaults, props or {})

  if type(props.nui) == 'function' then
    props.nui = props.nui()
  end

  setmetatable(props, self)
  self.__index = self

  if self.init_hook then
    props = self:init_hook(props)
  end

  return props
end

function M:mount(parent)
  if parent then
    self.parent = parent
  end

  if self.nui and not self.mounted then
    self.nui:mount()
    self.mounted = true
  end

  if self.mounts_children and self.children then
    for _, child in ipairs(self.children) do
      child:mount(self)
    end
  end
end

function M:unmount()
  if not self.mounted then
    return
  end

  if self.mounts_children and self.children then
    for _, child in ipairs(self.children) do
      child:unmount()
    end
  end

  if self.nui then
    self.nui:unmount()
  end

  self.mounted = false
end

return M
