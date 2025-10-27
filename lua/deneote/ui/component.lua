---@class ComponentProps
---@field visible? boolean
---@field children? Component[]
---@field parent? Component
---@field nui? NuiPopup | NuiLayout | fun(...): NuiPopup | fun(...): NuiLayout

---@class Component : ComponentProps
---@field nui? NuiPopup | NuiLayout
---@field mounted boolean
---@field new fun(self: Component, props?: ComponentProps): Component
---@field init_hook? fun(self: Component, props?: Component): Component Subclasses can define additional operations to perform during instantiation
---@field mount fun(self: Component, parent?: Component)
---@field unmount fun(self: Component)
local M = {}

M.defaults = {
  visible = true,
  children = nil,
  parent = nil,
  nui = nil,

  mounted = false,
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

  if props.init_hook then
    props:init_hook(props)
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

  if self.children then
    for _, child in ipairs(self.children) do
      child:mount(self)
    end
  end
end

function M:unmount()
  if not self.mounted then
    return
  end

  if self.children then
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
