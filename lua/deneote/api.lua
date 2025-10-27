local Config = require('deneote.config')
local Utils = require('deneote.utils')
local Form = require('deneote.ui.form')

local M = {}

M.commands = {
  create = function(_)
    vim.notify('Creating note!')

    -- Initiate prompts
    local fields = {} ---@type FormField[]

    if Config.options.prompts.workspace_dir then
      fields[#fields + 1] = {
        key = 'workspace',
        label = 'Enter workspace directory',
        default = Config.options.default_workspace_dir,
      }
    end

    if Config.options.prompts.file_type then
      fields[#fields + 1] = {
        key = 'filetype',
        label = 'Enter file type',
        default = Config.options.default_file_type,
      }
    end

    fields[#fields + 1] = {
      key = 'title',
      label = 'Enter title',
    }

    fields[#fields + 1] = {
      key = 'tags',
      label = 'Enter tags',
    }

    local form = Form:new(fields)

    form:mount(function(state)
      local title, tags = state.title, state.tags
      local workspace = state.workspace and state.workspace or Config.options.default_workspace_dir
      local filetype = state.filetype and state.filetype or Config.options.default_file_type

      local filestem = Utils.build_file_stem(Utils.make_timestamp(), title, tags)

      -- Invoke corresponding module to write to file
      if filetype == 'norg' then
        local neorg = require('deneote.modules.neorg')
        neorg.create_file(filestem, workspace)
      end
    end)
  end,
}

M.aliases = {
  create = { 'create_note' },
}

return M
