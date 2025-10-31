local Component = require('deneote.ui.component')
local input = require('nui.input')

---@class PromptComponentProps
---@field popup_options? nui_popup_options
---@field input_options? nui_input_options
---@field title? string

---@class PromptComponent: Component, PromptComponentProps
---@field nui NuiInput
---@field state Signal<{ text: string }>
local M = Component:new()

---@type PromptComponent
M.defaults = vim.tbl_deep_extend('force', {}, Component.defaults, {
  popup_options = {
    zindex = 100,
    position = '50%',
    relative = 'editor',
    size = { width = 30, height = 1 },
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
      default_value = instance.state:get_value().text,
      on_change = function(value)
        instance.state:next({ text = value })
      end,
      on_submit = function(value)
        instance.state:complete({ text = value })
      end,
    })
  )

  if instance.title ~= '' then
    instance.nui.border:set_text('top', ' ' .. instance.title .. ' ')
  end

  return instance
end

function M:on_update()
  self:modify_buffer_content(function()
    local buf = self.nui.bufnr or -1
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    local state = self.state:get_value().text

    local current =
      table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')

    if current ~= state then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { state })
    end
  end)
end

return M
