local Prompt = require('deneote.ui.prompt')

---@class FormField
---@field key string
---@field label string
---@field default? string
---@field opts? PromptComponent}[]

---@class FormHandler
---@field fields FormField[]
---@field results table<string, string>
---@field new fun(self: FormHandler, fields: FormField): FormHandler
---@field mount fun(self: FormHandler, callback: fun(state: table<string, string>))
local M = {}

---@param fields FormField[]
function M:new(fields)
  local form = { fields = fields, results = {} }

  setmetatable(form, self)
  self.__index = self

  return form
end

---@param callback fun(state: table<string, string>)
function M:mount(callback)
  local i = 1

  local function next_prompt()
    if i > #self.fields then
      if callback then
        callback(self.results)
      end
      return
    end

    local field = self.fields[i]
    i = i + 1

    local prompt = Prompt:new({
      title = field.label,
      input_opts = vim.tbl_extend('force', field.opts or {}, { default_value = field.default }),
      on_submit = function(state)
        self.results[field.key] = state
        next_prompt()
      end,
    })

    prompt:mount()
  end

  next_prompt()
end

return M
