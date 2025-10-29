local Component = require('deneote.ui.component')
local input = require('nui.input')

---@class PromptComponentProps
---@field popup_opts nui_popup_options
---@field input_opts nui_input_options
---@field title string

---@class PromptComponent: Component, PromptComponentProps
---@field nui NuiInput
---@field state { text: string }
local Prompt = Component:new()

---@type PromptComponent
Prompt.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  popup_opts = {
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
  input_opts = {},
  title = '',
  state = {
    text = '',
  },
})

---@param instance PromptComponent
---@return PromptComponent
function Prompt:init(instance)
  instance.nui = input(
    instance.popup_opts,
    vim.tbl_extend('force', instance.input_opts, {
      default_value = instance.state.text,
      on_change = function(value)
        instance:set_state({ text = value })
        instance:emit('change', value)
      end,
      on_submit = function(value)
        instance:unmount()
        instance:set_state({ text = value })
        instance:emit('submit', value)
      end,
    })
  )

  if instance.title ~= '' then
    instance.nui.border:set_text('top', ' ' .. instance.title .. ' ')
  end

  return instance
end

return Prompt
