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

---Remove illegal slug characters from a string
---@param s string
---@return string
function M.slug_sanitize(s)
  s = s or ''
  -- Remove illegal filename characters
  s = s:gsub('[/\\?%%*:|"<>]', '')
  -- Replace non-ASCII characters with spaces
  s = s:gsub('[^%z\1-\127]', ' ')
  -- Remove punctuation, symbols
  s = s:gsub('[%[%]{}!@#%$%%%^&%*%(%)+\'",%.|;:~`‘’“”/=]+', '')
  return s
end

---Replace whitespace, underscores, multiple hyphens with single hyphens; trim.
---@param s string
---@return string
function M.slug_hyphenate(s)
  s = s or ''
  -- Replace whitespace and underscores with hyphens
  s = s:gsub('[%s%_]', '-')
  -- Replace multiple hyphens with single
  s = s:gsub('%-+', '-')
  -- Remove leading/trailing hyphens
  s = s:gsub('^%-+', ''):gsub('%-+$', '')
  return s
end

---Generate file identifier from current time
---@return string
function M.make_timestamp()
  return vim.fn.strftime('%Y%m%dT%H%M%S')
end

---Downcases, hyphenates, de-punctuates, and removes spaces from string.
---@param s string
---@return string
function M.sluggify_title(s)
  s = s or ''
  s = s:lower()
  s = M.slug_sanitize(s)
  s = M.slug_hyphenate(s)
  return s
end

---Downcases, de-punctuates, and removes delimiters from string.
function M.sluggify_tag(s)
  s = s or ''
  s = M.sluggify_title(s)
  s = s:gsub('%-', '')
  return s
end

---Builds normalized file stem: `id--title-str__tag_str`
---@param id string
---@param title string
---@param tag_str string Comma-separated string of tags
---@return string, string, string[]
function M.build_file_stem(id, title, tag_str)
  title = M.sluggify_title(title)
  local tags = M.map(vim.split(tag_str, ','), M.sluggify_tag)

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
