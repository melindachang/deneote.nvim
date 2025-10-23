local Object = require('deneote.middleclass')
local Popup = require('nui.popup')

---@class Component
local Component = Object('Component')

---@class (exact) ComponentProps
---@field id? string
---@field visible? boolean
---@field children? Component[]
---@field parent? Component
---@field nui_props? nui_popup_options
Component.defaults = {
  id = nil,
  visible = true,
  children = nil,
  parent = nil,
  nui_props = {},
}

---@param props ComponentProps
function Component:init(props)
  self.options = vim.tbl_deep_extend('force', {}, self.defaults, props or {})
  self.nui = Popup(self.options.nui_props or {})
end

---@param parent? Component
function Component:mount(parent)
  self.options.parent = parent
end

---@param new_props Component
function Component:update(new_props)
  self.options = vim.tbl_deep_extend('force', self.defaults, new_props or {})
end

function Component:unmount() end

-- Lifecycle hooks
function Component:on_mount() end
function Component:on_unmount() end

---@param new_props ComponentProps
function Component:on_update(new_props) end

---@param event string
---@param payload? any
function Component:on_event(event, payload) end

return Component
