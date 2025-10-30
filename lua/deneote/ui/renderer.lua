local Signal = require('deneote.ui.signal')
local Utils = require('deneote.utils')
local layout = require('nui.layout')
local box = layout.Box

---@class RendererProps
---@field layout_options? nui_layout_options

---@class Renderer: RendererProps
---@field children? Component[]
---@field nui? NuiLayout
---@field layout_box? NuiLayout.Box
local M = {}

---@type Renderer
M.defaults = {
  layout_options = {
    position = '50%',
    relative = 'editor',
    size = {
      width = 80,
      height = 40,
    },
  },
}

function M:new(props)
  local instance = vim.tbl_deep_extend('force', {}, self.defaults, props or {})

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param child Component
function M:add_child(child)
  self.children = self.children or {}
  table.insert(self.children, child)
end

function M:render()
  if self.children then
    local components = Utils.map(self.children, function(child)
      return child:render()
    end)

    self.nui = layout(self.layout_options, box(components, { dir = 'col' }))
  end

  vim.schedule(function()
    self.nui:mount()
  end)
end

return M
