local Renderer = require('deneote.ui.renderer')
local Prompt = require('deneote.ui.prompt')
local Menu = require('deneote.ui.menu')
local WildMenu = require('deneote.ui.wildmenu')
local Flow = require('deneote.ui.flow')

local Config = require('deneote.config')
local fs = require('deneote.utils.fs')

local M = {}

---Create note using flow-controlled prompts
function M.create(_) -- TODO: support args
  local renderer = Renderer:new()
  local flow = Flow:new(renderer)

  flow
    :add_step('title', function()
      return Prompt:new({
        title = ' Title',
        box_options = { grow = 0 },
      })
    end)
    :add_step('keywords', function()
      if #Config.options.known_keywords > 0 then
        return WildMenu:new({
          title = '󰓹 Keywords',
          items = Config.options.known_keywords,
        })
      else
        return Prompt:new({
          title = '󰓹 Keywords',
          box_options = { grow = 0 },
        })
      end
    end)

  if Config.options.prompts.workspace_dir then
    flow:add_step('workspace', function()
      return Prompt:new({ title = ' Workspace directory' })
    end)
  end

  if Config.options.prompts.file_type then
    flow:add_step('filetype', function()
      return Menu:new({ title = ' File type', items = { 'norg' } })
    end)
  end

  flow.on_complete = function(results)
    local payload = {
      title = results.title,
      keywords = results.keywords,
      workspace = results.workspace and fs.normalize_path(results.workspace)
        or Config.options.default_workspace_dir,
      filetype = results.filetype or Config.options.default_file_type,
    }

    -- Invoke corresponding module to write to file
    if payload.filetype == 'norg' then
      require('deneote.modules.neorg').create_file(payload)
    end
  end

  flow:start()
end

return M
