local NeorgDirman = require('neorg').modules.get_module('core.dirman')
assert(NeorgDirman, 'module core.dirman not found')

local NeorgMetagen = require('neorg').modules.get_module('core.esupports.metagen')
assert(NeorgMetagen, 'module core.esupports.metagen not found')

local Utils = require('deneote.utils')

local M = {}

---Write to Neorg file with metagen
---@param payload { title: string, tags: string, workspace: string, filetype: string }
function M.create_file(payload)
  local ts = Utils.make_timestamp()
  local stem, title, tags = Utils.build_file_stem(ts, payload.title, payload.tags)
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
          return string.format('[\n  %s\n]', table.concat(tags, '\n  '))
        end,
        created = neorg_ts,
        updated = neorg_ts,
      })

      vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)
      vim.api.nvim_set_current_buf(buf)
    else
      vim.notify('File already exists!')
    end
  end
end

---Convert filestem timestamp to Neorg-compatible format
---@param id string
---@return string
function M.filestem_to_iso(id)
  local year, month, day = id:sub(1, 4), id:sub(5, 6), id:sub(7, 8)
  local hour, min, sec = id:sub(10, 11), id:sub(12, 13), id:sub(14, 15)

  local timestamp = string.format('%s-%s-%sT%s:%s:%s', year, month, day, hour, min, sec)

  -- append local timezone offset
  local tz_offset = os.date('%z') -- returns like -0500
  timestamp = timestamp .. tz_offset

  return timestamp
end

---Get workspace name by path
---@param path string
---@return string | false
function M.get_workspace_name(path)
  local workspaces = NeorgDirman.get_workspaces() ---@type table<string, PathlibPath>

  for name, path_obj in pairs(workspaces) do
    if Utils.normalize_path(path_obj:absolute('/'):tostring()) == path then
      return name
    end
  end

  return false
end

return M
