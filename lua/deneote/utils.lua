local M = {}

---Maps values of an array with function
---@generic T
---@generic K
---@param tbl T[]
---@param proc fun(T): K
---@return K[]
function M.map(tbl, proc)
  local res = {}

  for i, v in ipairs(tbl) do
    res[i] = proc(v)
  end

  return res
end

---Trims whitespace, dashes, underscores from ends of string
---@param s string
---@return string
function M.trim(s)
  s = s or ''
  local match = '[%s%-%_]+'
  return (s:gsub('^' .. match, ''):gsub(match .. '$', ''))
end

---Remove illegal filename characters from a string
---@param s string
---@return string
function M.sanitize_filename(s)
  s = s or ''
  return (s:gsub('[/\\?%*:|"<>]', ''))
end

---Generate file identifier from current time
---@return string
function M.make_timestamp()
  return vim.fn.strftime('%Y%m%dT%H%M%S')
end

---Reduces sequential function applications by proc'cing on an initial value
---@generic T
---@param value T
---@param ... function
---@return T
function M.pipe(value, ...)
  local result = value
  for _, fn in ipairs({ ... }) do
    if not result then
      result = ''
    end
    result = fn(result)
  end
  return result
end

---Builds normalized file stem: `id--title-str__tag_str`
---@param id string
---@param title string
---@param tag_str string Comma-separated string of tags
---@return string, string, string[]
function M.build_file_stem(id, title, tag_str)
  assert(title, 'should contain title')
  assert(tag_str, 'should contain title')

  title = M.pipe(title, M.trim, M.sanitize_filename, function(s)
    return s:gsub('[%s%_]+', '-'):gsub('-+', '-')
  end)

  local tags = {} ---@type string[]
  for tag in vim.gsplit(tag_str, ',') do
    tag = M.pipe(tag, M.trim, M.sanitize_filename, function(s)
      return s:gsub('[%s_]+', '-'):gsub('-+', '-')
    end)
    if tag then
      tags[#tags + 1] = tag
    end
  end
  tag_str = table.concat(tags, '_')

  return id .. '--' .. title .. '__' .. tag_str, title, vim.split(tag_str, '_')
end

---Resolves every path to the same object to a normal (absolute) path
---@param path string
---@return string
function M.normalize_path(path)
  return vim.fs.abspath(vim.fs.normalize(path))
end

return M
