---@alias DeneoteFileType 'norg' | 'org'

---@class DeneoteCoreConfig
local M = {}

---@class DeneoteConfig
M.defaults = {
  -- Optionally provide a function to be called on Deneote startup
  ---@type fun(manual: boolean, arguments?: string)
  hook = nil,

  -- Directory where modules will be installed
  root = vim.fs.joinpath(vim.fn.stdpath('data'), 'deneote'),

  -- New notes will be stored in this directory
  default_workspace_dir = vim.env.HOME .. '/notes',

  -- New notes will be configured for this file type
  ---@type DeneoteFileType
  default_file_type = 'norg',

  -- Set to `true` to provide values on a per-file basis
  prompts = {
    workspace_dir = false, -- overrides `DeneoteConfig.default_workspace_dir`
    file_type = false, -- overrides `DeneoteConfig.default_file_type`
  },
}

---@type DeneoteConfig
M.options = {}

---@param opts? DeneoteConfig
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})

  M.options.root = vim.fs.normalize(M.options.root)
  M.options.default_workspace_dir = vim.fs.normalize(M.options.default_workspace_dir)
end

return M
