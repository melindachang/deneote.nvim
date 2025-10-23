local Config = require('deneote.config')
local Utils = require('deneote.utils')

local M = {}

---@param opts DeneoteConfig
function M.setup(opts)
  Config.setup(opts)
end

return M
