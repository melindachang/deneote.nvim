---@class Renderer
local M = {}

---@param opts Renderer
---@return Renderer
function M:new(opts)
  opts = opts or {}
  setmetatable(opts, self)
  self.__index = self
  return opts
end

---@param content Component | fun(): Component
function M:render(content)
  if type(content) == 'function' then
    content = content()
  end
end

return M
