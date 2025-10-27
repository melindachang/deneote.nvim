local Component = require('deneote.ui.component')
local Layout = require('nui.layout')

---@class FormComponent : Component
---@field nui? NuiLayout
---@field nui_opts? nui_layout_options
local M = Component:new()

function M:init_hook()
  if self.children then
    ---@type NuiLayout.Box[]
    local fields = {}

    for _, child in ipairs(self.children) do
      if child.nui then
        table.insert(fields, Layout.Box(child.nui, { size = '100%' }))
      end
    end

    self.nui = Layout(self.nui_opts or {}, Layout.Box(fields, { dir = 'col' }))
  end
end

return M
