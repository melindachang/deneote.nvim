local NeorgDirman = require('neorg').modules.get_module('core.dirman')
assert(NeorgDirman, 'module core.dirman not found')

local NeorgMetagen =
  require('neorg').modules.get_module('core.esupports.metagen')
assert(NeorgMetagen, 'module core.esupports.metagen not found')

local fs = require('deneote.utils.fs')

local M = {}

---Write to Neorg file with metagen
---@param payload { title: string, keywords: string, workspace: string, filetype: string }
function M.create_file(payload)
  local ts = fs.make_timestamp()
  local stem, title, keywords =
    fs.build_file_stem(ts, payload.title, payload.keywords)
  local neorg_ts = M.filestem_to_iso(ts)

  local ws = M.get_workspace_name(payload.workspace)

  if ws then
    local path = vim.fs.joinpath(payload.workspace, stem .. '.norg')
    local buf = vim.fn.bufadd(path)
    vim.fn.bufload(buf)
    vim.bo[buf].filetype = 'norg'

    local present = NeorgMetagen.is_metadata_present(buf)

    if not present then
      local lines = NeorgMetagen.construct_metadata(buf, {
        title = title,
        categories = function()
          return string.format('[\n  %s\n]', table.concat(keywords, '\n  '))
        end,
        created = neorg_ts,
        updated = neorg_ts,
      })

      vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)
      vim.api.nvim_set_current_buf(buf)
    else
      vim.notify('File already exists!')
    end
  else
    -- TODO: handle nonexistent workspace
  end
end

---Convert filestem timestamp to Neorg-compatible format
---@param id string
---@return string
function M.filestem_to_iso(id)
  local year, month, day = id:sub(1, 4), id:sub(5, 6), id:sub(7, 8)
  local hour, min, sec = id:sub(10, 11), id:sub(12, 13), id:sub(14, 15)

  local timestamp =
    string.format('%s-%s-%sT%s:%s:%s', year, month, day, hour, min, sec)

  local tz_offset = M.get_timezone_offset()
  local h, m = math.modf(tz_offset / 3600)
  timestamp = timestamp .. string.format('%+.4d', h * 100 + m * 60)

  return timestamp
end

---Get workspace name by path
---@param path string
---@return string | false
function M.get_workspace_name(path)
  local workspaces = NeorgDirman.get_workspaces() ---@type table<string, PathlibPath>

  for name, path_obj in pairs(workspaces) do
    if fs.normalize_path(path_obj:absolute('/'):tostring()) == path then
      return name
    end
  end

  return false
end

---Calculate timezone offset as Neorg does
---@return integer
function M.get_timezone_offset()
  local utcdate = os.date('!*t', 0)
  local localdate = os.date('*t', 0)
  localdate.isdst = false -- this is the trick
  return os.difftime(os.time(localdate), os.time(utcdate)) ---@diagnostic disable-line -- TODO: type error workaround <pysan3>
end

return M
