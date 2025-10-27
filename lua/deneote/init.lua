local Config = require('deneote.config')
local Cmd = require('deneote.cmd')
local Utils = require('deneote.utils')

local M = {}

---@param opts DeneoteConfig
function M.setup(opts)
  Config.setup(opts)
  Cmd.setup()
end

return M
