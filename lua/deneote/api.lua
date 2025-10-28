local Config = require('deneote.config')
local Form = require('deneote.ui.form')
local Utils = require('deneote.utils')

local M = {}

M.commands = {
  create = function(_)
    -- Configure prompts
    local fields = {} ---@type FormField[]

    for _, opt in ipairs({
      {
        key = 'workspace',
        enabled = Config.options.prompts.workspace_dir,
        default = Config.options.default_workspace_dir,
        label = 'Enter workspace directory',
      },
      {
        key = 'filetype',
        enabled = Config.options.prompts.file_type,
        default = Config.options.default_file_type,
        label = 'Enter file type',
      },
      { key = 'title', enabled = true, label = 'Enter title' },
      { key = 'tags', enabled = true, label = 'Enter tags' },
    }) do
      if opt.enabled then
        fields[#fields + 1] = { key = opt.key, label = opt.label, default = opt.default or nil }
      end
    end

    local form = Form:new(fields)

    -- Form callback
    form:mount(function(state)
      local payload = {
        title = state.title,
        tags = state.tags,
        workspace = state.workspace and Utils.normalize_path(state.workspace)
          or Config.options.default_workspace_dir,
        filetype = state.filetype or Config.options.default_file_type,
      }

      -- Invoke corresponding module to write to file
      if payload.filetype == 'norg' then
        require('deneote.modules.neorg').create_file(payload)
      end
    end)
  end,
}

M.aliases = {
  create = { 'create_note' },
}

return M
