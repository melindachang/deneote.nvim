local Component = require('deneote.ui.component')
local Input = require('nui.input')

---@alias EventHandler fun(state: string)

---@class PromptComponentProps: ComponentProps
---@field nui_opts? nui_popup_options
---@field input_opts? nui_input_options
---@field title? string
---@field on_submit? EventHandler

---@class PromptComponent: Component, PromptComponentProps
---@field nui? NuiInput
local M = Component:new()

M.defaults = {
  nui_opts = {
    zindex = 100,
    position = '50%',
    relative = 'win',
    size = {
      width = 30,
      height = 5,
    },
    enter = false,
    focusable = true,
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
  title = '',
  on_submit = nil,
}

---@param props PromptComponent
---@return PromptComponent
function M:init_hook(props)
  props.nui = Input(
    vim.tbl_deep_extend(
      'force',
      props.nui_opts or {},
      { border = { text = { top = ' ' .. props.title .. ' ' } } }
    ),

    vim.tbl_deep_extend('force', props.input_opts or {}, { on_submit = props.on_submit })
  )

  return props
end

return M
