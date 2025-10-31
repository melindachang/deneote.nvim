---@class FlowController
---@field renderer Renderer
---@field steps { key: string, factory: fun(): Component }[]
---@field index number
---@field results table
---@field current? Component
---@field on_complete? fun(...): nil
local M = {}

---@param renderer Renderer
---@return FlowController
function M:new(renderer)
  self.__index = self

  return setmetatable({
    renderer = renderer,
    steps = {},
    index = 0,
    results = {},
  }, self)
end

---@param key string
---@param factory fun(): Component
function M:add_step(key, factory)
  table.insert(self.steps, { key = key, factory = factory })
  return self
end

function M:start()
  self:next_step()
end

function M:next_step()
  self.index = self.index + 1
  if self.index > #self.steps then
    -- all done
    if self.on_complete then
      self.on_complete(self.results)
    end
    return
  end

  local step = self.steps[self.index]

  -- create component
  local component = step.factory()
  self.current = component

  self.renderer:add_child(component)
  self.renderer:render()

  component:watch({
    complete = function(value)
      vim.schedule(function()
        if type(value) == 'table' and value.text then
          self.results[step.key] = value.text
        else
          self.results[step.key] = value
        end
        self.renderer.children = {}

        self:next_step()
      end)
    end,
  })
end

return M
