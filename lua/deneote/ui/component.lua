---@class ComponentProps
---@field visible? boolean
---@field children? Component[]
---@field parent? Component
---@field nui? NuiPopup | fun(...): NuiPopup

---@class Component : ComponentProps
---@field nui? NuiPopup
---@field mounted boolean
---@field new fun(self: Component, props?: ComponentProps): Component
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
  props = vim.tbl_deep_extend('force', M.defaults, props or {})

  if type(props.nui) == 'function' then
    props.nui = props.nui()
  end

  setmetatable(props, self)
  self.__index = self

  return props
end

function M:mount(parent)
  if self.nui then
    self.nui:mount()
    self.mounted = true

    if self.children then
      for _, child in self.children do
        child:mount(self)
      end
    end
  end
end

function M:unmount()
  if self.mounted and self.nui then
    if self.children then
      for _, child in self.children do
        child:unmount(self)
      end
    end

    self.nui:unmount()
    self.mounted = false
  end
end

return M
