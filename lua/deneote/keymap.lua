local M = {}

---@alias ModeShortName 'n' | 'i' | 'v' | 'x' | 's' | 'o' | 'c' | 't'

---@class Keymaps: vim.keymap.set.Opts
---@field lhs string
---@field rhs string|fun()
---@field desc? string
---@field mode? ModeShortName

---@type Keymaps[]
M.defaults = {
  {
    lhs = '<leader>dn',
    rhs = ':Deneote create<CR>',
    desc = 'Create new note',
    mode = 'n',
  },
}

---@param maps? Keymaps[]
function M.setup(maps)
  maps = maps or M.defaults
  for _, map in ipairs(maps) do
    vim.keymap.set(
      map.mode,
      map.lhs,
      map.rhs,
      { desc = map.desc, silent = true }
    )
  end
end

return M
