local M = {}

---Maps values of an array with function
---@generic T
---@generic K
---@param tbl T[]
---@param proc fun(T): K
---@return K[]
function M.map(tbl, proc)
  local proc_result = {}

  for _, val in ipairs(tbl) do
    table.insert(proc_result, proc(val))
  end

  return proc_result
end

---Splits a string into array of strings at specified delimiter
---@param input string
---@param delimiter string
---@return string[]
function M.split_str(input, delimiter)
  local parts = {}

  for part in input:gmatch('([^' .. delimiter .. ']+)') do
    table.insert(parts, part)
  end

  return parts
end

---Remove illegal filename characters from a string
---@param str string
---@param sub string
---@return string
function M.sanitize_file_str(str, sub)
  str = str:gsub('[/\\?%*:|"<>]', sub)
  return str
end

---Generate file identifier from current time
---@return string
function M.make_timestamp()
  return vim.fn.strftime('%Y%m%dT%H%M%S')
end

---Builds normalized file stem according to the format `id--title-str__tag_str`
---@param id string
---@param title string
---@param tag_str string Comma-separated string of tags
---@return string
function M.build_file_stem(id, title, tag_str)
  title = M.sanitize_file_str(title, '-'):gsub('[%s%-]+', '-')
  local tags = M.split_str(tag_str, ',')
  tags = M.map(tags, function(tag)
    tag = M.sanitize_file_str(tag, ''):gsub('_+', '')
    return tag
  end)
  tag_str = table.concat(tags, '_')

  return id .. '--' .. title .. '__' .. tag_str
end

return M
