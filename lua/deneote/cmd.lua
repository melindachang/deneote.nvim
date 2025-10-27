local Api = require('deneote.api')

local M = {}

function M.cmd(cmd, opts)
  local command = Api.commands[cmd]
  if command then
    command(opts)
  else
    M.error('unknown command: ' .. cmd, { title = 'Arrow' })
  end
end

---@param args string
function M.parse(args)
  local parts = vim.split(vim.trim(args), '%s+')
  if parts[1]:find('Deneote') then
    table.remove(parts, 1)
  end

  if args:sub(-1) == ' ' then
    parts[#parts + 1] = ''
  end

  return table.remove(parts, 1) or '', parts
end

function M.setup()
  vim.api.nvim_create_user_command('Deneote', function(cmd)
    local opts = {}
    local prefix = M.parse(cmd.args)

    M.cmd(prefix, opts)
  end, {
    nargs = '?',
    desc = 'Deneote',
    complete = function(_, line)
      local prefix = M.parse(line)
      return vim.tbl_filter(function(key)
        return key:find(prefix, 1, true) == 1
      end, vim.tbl_keys(Api.commands))
    end,
  })
end

function M.error(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.ERROR
  vim.notify(msg, opts)
end

return M
