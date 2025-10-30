---@alias CallbackFn fun(...): nil
---@alias SignalSubscriber<T> { next?: fun(value: T), complete?: fun(value: T), error?: fun(err: any) }

---@class Signal<T>
---@field _value T
---@field _subscribers SignalSubscriber<T>[]
---@field _completed boolean
local M = {}

---@generic T: table
---@param initial_value T
---@return Signal<T>
function M:new(initial_value)
  self.__index = self
  return setmetatable(
    { _value = initial_value, _subscribers = {}, _completed = false },
    self
  )
end

---Subscribe to signal updates
---@param opts SignalSubscriber<T>
function M:subscribe(opts)
  if self._completed then
    if opts.complete then
      opts.complete(self._value)
    end
    return
  end

  table.insert(self._subscribers, opts)
end

---@param partial? table
function M:_set_value(partial)
  self._value = vim.tbl_extend('force', self._value, partial or {})
end

---Emit a regular update
---@param value table
function M:next(value)
  if self._completed then
    return
  end

  self:_set_value(value)
  for _, subscriber in ipairs(self._subscribers) do
    if subscriber.next then
      subscriber.next(self._value)
    end
  end
end

---Mark the signal as completed.
---@param value? table
function M:complete(value)
  value = value or {}

  if self._completed then
    return
  end

  self._completed = true
  self:_set_value(value)

  for _, subscriber in ipairs(self._subscribers) do
    if subscriber.complete then
      subscriber.complete(self._value)
    end
  end
  self._subscribers = {}
end

---Emit an error and terminate.
---@param err any
function M:error(err)
  if self._completed then
    return
  end
  self._completed = true
  for _, subscriber in ipairs(self._subscribers) do
    if subscriber.error then
      subscriber.error(err)
    end
  end
  self._subscribers = {}
end

function M:get_value()
  return self._value
end

return M
