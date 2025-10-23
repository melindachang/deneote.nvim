-- from `kikito/middleclass`

---@class Class : Mixin
---@field name string
---@field super? table
---@field __instanceDict table
---@field __declaredMethods table
---@field subclasses table<Class>

---@class Middleclass
---@field class fun(name: string, super?: Class): Class
local middleclass = {}

local function _createIndexWrapper(class, f)
  if f == nil then
    return class.__instanceDict
  elseif type(f) == 'function' then
    return function(self, name)
      local value = class.__instanceDict[name]

      if value ~= nil then
        return value
      else
        return (f(self, name))
      end
    end
  else -- if  type(f) == "table" then
    return function(self, name)
      local value = class.__instanceDict[name]

      if value ~= nil then
        return value
      else
        return f[name]
      end
    end
  end
end

local function _propagateInstanceMethod(class, name, f)
  f = name == '__index' and _createIndexWrapper(class, f) or f
  class.__instanceDict[name] = f

  for subclass in pairs(class.subclasses) do
    if rawget(subclass.__declaredMethods, name) == nil then
      _propagateInstanceMethod(subclass, name, f)
    end
  end
end

local function _declareInstanceMethod(class, name, f)
  class.__declaredMethods[name] = f

  if f == nil and class.super then
    f = class.super.__instanceDict[name]
  end

  _propagateInstanceMethod(class, name, f)
end

local function _tostring(self)
  return 'class ' .. self.name
end

local function _call(self, ...)
  return self:new(...)
end

---@param name string
---@param super? table | fun(...): table
---@return Class
local function _createClass(name, super)
  local dict = {}
  dict.__index = dict

  local class = {
    name = name,
    super = super,
    static = {},
    __instanceDict = dict,
    __declaredMethods = {},
    subclasses = setmetatable({}, { __mode = 'k' }),
  }

  if super then
    setmetatable(class.static, {
      __index = function(_, k)
        local result = rawget(dict, k)
        if result == nil then
          return super.static[k]
        end
        return result
      end,
    })
  else
    setmetatable(class.static, {
      __index = function(_, k)
        return rawget(dict, k)
      end,
    })
  end

  setmetatable(class, {
    __index = class.static,
    __tostring = _tostring,
    __call = _call,
    __newindex = _declareInstanceMethod,
  })

  return class
end

---@param class Class
---@param mixin Mixin
---@return Class
local function _includeMixin(class, mixin)
  assert(type(mixin) == 'table', 'mixin must be a table')

  for name, method in pairs(mixin) do
    if name ~= 'included' and name ~= 'static' then
      class[name] = method
    end
  end

  for name, method in pairs(mixin.static or {}) do
    class.static[name] = method
  end

  if type(mixin.included) == 'function' then
    mixin:included(class)
  end
  return class
end

---@class Mixin
---@field included? function Hook called after Class:include(mixin)
local DefaultMixin = {
  __tostring = function(self)
    return 'instance of ' .. tostring(self.class)
  end,

  init = function(self, ...) end,

  isInstanceOf = function(self, class)
    return type(class) == 'table'
      and type(self) == 'table'
      and (
        self.class == class
        or type(self.class) == 'table'
          and type(self.class.isSubclassOf) == 'function'
          and self.class:isSubclassOf(class)
      )
  end,

  static = {
    allocate = function(self)
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'"
      )
      return setmetatable({ class = self }, self.__instanceDict)
    end,

    new = function(self, ...)
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:new' instead of 'Class.new'"
      )
      local instance = self:allocate()
      instance:init(...)
      return instance
    end,

    subclass = function(self, name)
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'"
      )
      assert(type(name) == 'string', 'You must provide a name(string) for your class')

      local subclass = _createClass(name, self)

      for methodName, f in pairs(self.__instanceDict) do
        if not (methodName == '__index' and type(f) == 'table') then
          _propagateInstanceMethod(subclass, methodName, f)
        end
      end
      subclass.init = function(instance, ...)
        return self.init(instance, ...)
      end

      self.subclasses[subclass] = true
      self:subclassed(subclass)

      return subclass
    end,

    subclassed = function(self, other) end,

    isSubclassOf = function(self, other)
      return type(other) == 'table'
        and type(self.super) == 'table'
        and (self.super == other or self.super:isSubclassOf(other))
    end,

    include = function(self, ...)
      assert(
        type(self) == 'table',
        "Make sure you that you are using 'Class:include' instead of 'Class.include'"
      )
      for _, mixin in ipairs({ ... }) do
        _includeMixin(self, mixin)
      end
      return self
    end,
  },
}

---@generic T: Class
---@param name string
---@param super? table | fun(...): table
---@return T
function middleclass.class(name, super)
  assert(type(name) == 'string', 'A name (string) is needed for the new class')
  return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
end

setmetatable(middleclass, {
  __call = function(_, ...)
    return middleclass.class(...)
  end,
})

return middleclass
