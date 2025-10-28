local Config = require('deneote.config')
local Cmd = require('deneote.cmd')
local Keymap = require('deneote.keymap')

local M = {}

---@param opts DeneoteUserConfig
function M.setup(opts)
  Config.setup(opts)
  Cmd.setup()
  Keymap.setup()
end

return M
