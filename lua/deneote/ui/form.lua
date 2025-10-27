local Component = require('deneote.ui.component')
local Layout = require('nui.layout')

---@class FormComponent : Component
---@field nui? NuiLayout
---@field nui_opts? nui_layout_options
local M = Component:new()

---@param props? FormComponent
---@return FormComponent
function M:init_hook(props)
  props = props or {}

  if props.children then
    ---@type NuiLayout.Box[]
    local fields = {}

    for _, child in ipairs(props.children) do
      if child.nui then
        table.insert(fields, Layout.Box(child.nui, { size = '100%' }))
      end
    end

    props.nui = Layout(props.nui_opts or {}, Layout.Box(fields, { dir = 'col' }))
  end

  return props
end

return M
