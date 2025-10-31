local M = {}

---Maps values of table with function
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

---Filters out entries in table that do not contain a string
---@param tbl string[]
---@param value string
---@return table
function M.filter_completions(tbl, value)
  -- Check if user has typed yet
  if value == '' or #tbl == 0 then
    return tbl
  end

  return vim.tbl_filter(function(item)
    return item:lower():find(value:lower(), 1, true)
  end, tbl)
end

---Removes duplicates from array-like table
---@generic T: table
---@param tbl T
---@return T
function M.dedup_array(tbl)
  local res = {}
  local seen = {}

  for _, value in ipairs(tbl) do
    if not seen[value] then
      table.insert(res, value)
      seen[value] = true
    end
  end

  return res
end

return M
