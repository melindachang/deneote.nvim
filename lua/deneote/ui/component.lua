---@class Component
local M = {}

---@param opts Component
---@return Component
function M:new(opts)
  opts = opts or {}
  setmetatable(opts, self)
  self.__index = self
  return opts
end

return M
