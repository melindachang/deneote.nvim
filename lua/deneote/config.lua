local fs = require('deneote.utils.fs')

---@alias DeneoteFileType 'norg'
----| 'org'

---@class DeneoteCoreConfig
local M = {}

---@class DeneoteConfig
---@field hook? fun(manual: boolean, arguments?: string)
---@field root string
---@field default_workspace_dir string
---@field default_file_type DeneoteFileType
---@field known_keywords string[]
local defaults = {
  -- Optionally provide a function to be called on Deneote startup
  hook = nil,

  -- Directory where modules will be installed
  root = vim.fn.stdpath('data') .. '/deneote',

  -- New notes will be stored in this directory
  default_workspace_dir = '~/notes',

  -- New notes will be configured for this file type
  default_file_type = 'norg',

  -- Provide list of strings to suggest in the keyword prompt
  known_keywords = {},

  -- Set to `true` to provide values on a per-file basis
  prompts = {
    workspace_dir = false, -- overrides `DeneoteConfig.default_workspace_dir`
    file_type = false, -- overrides `DeneoteConfig.default_file_type`
  },
}

---@class DeneoteUserConfig: DeneoteConfig
---@field hook? fun(manual: boolean, arguments?: string)
---@field root? string
---@field default_workspace_dir? string
---@field default_file_type? DeneoteFileType

---@param opts? DeneoteUserConfig
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', defaults, opts or {}) ---@type DeneoteConfig

  M.options.root = fs.normalize_path(M.options.root)
  M.options.default_workspace_dir =
    fs.normalize_path(M.options.default_workspace_dir)
end

return M
