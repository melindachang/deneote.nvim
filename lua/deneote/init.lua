local Config = require('deneote.config')
local Utils = require('deneote.utils')

local M = {}

---@param opts DeneoteConfig
function M.setup(opts)
  Config.setup(opts)
end

---@param args? string
function M.create_note(args)
  -- Initiate prompts
  local title, tags, workspace, filetype

  local filestem = Utils.build_file_stem(Utils.make_timestamp(), title, tags)

  -- Invoke corresponding module to write to file
  if filetype == 'norg' then
    local neorg = require('deneote.modules.neorg')
    neorg.create_file(filestem, workspace)
  end
end

return M
