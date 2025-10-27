local Component = require('deneote.ui.component')
local Popup = require('nui.popup')

---@class PromptComponent : Component
---@field nui? NuiPopup
---@field nui_opts? nui_popup_options
local M = Component:new()

---@param props? PromptComponent
---@return PromptComponent
function M:init_hook(props)
  props = props or {}

  if not props.nui and props.nui_opts then
    props.nui = Popup(props.nui_opts)
  end

  return props
end

return M
