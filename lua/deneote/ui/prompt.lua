local Component = require('deneote.ui.component')
local Popup = require('nui.popup')

---@class PromptComponent : Component
---@field nui? NuiPopup
---@field nui_opts? nui_popup_options
local M = Component:new()

function M:init_hook()
  if not self.nui and self.nui_opts then
    self.nui = Popup(self.nui_opts)
  end
end

return M
