local Component = require('deneote.ui.component')
local input = require('nui.input')

---@class PromptComponentProps
---@field popup_options? nui_popup_options
---@field input_options? nui_input_options
---@field title? string

---@class PromptComponent: Component, PromptComponentProps
---@field nui NuiInput
---@field _state Signal<{ text: string }>
local M = Component:new()

---@type PromptComponent
M.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  popup_options = {
    zindex = 100,
    position = '50%',
    relative = 'editor',
    size = { width = 30, height = 5 },
    border = {
      padding = { 0, 1, 0, 1 },
      style = 'rounded',
      text = {
        top_align = 'left',
      },
    },
    win_options = {
      winblend = 7,
      winhighlight = 'FloatTitle:Title,FloatBorder:Normal,NormalFloat:Normal',
    },
  },
  input_options = {},
  title = '',
  initial_state = {
    text = '',
  },
})

---@param instance PromptComponent
---@return PromptComponent
function M:init(instance)
  instance.nui = input(
    instance.popup_options,
    vim.tbl_extend('force', instance.input_options, {
      default_value = instance._state:get_value().text,
      on_change = function(value)
        instance._state:next({ text = value })
      end,
      on_submit = function(value)
        instance._state:complete({ text = value })
      end,
    })
  )

  if instance.title ~= '' then
    instance.nui.border:set_text('top', ' ' .. instance.title .. ' ')
  end

  return instance
end

return M
