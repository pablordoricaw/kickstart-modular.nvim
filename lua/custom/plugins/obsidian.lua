-- Function to check if Obsidian app is installed
local function is_obsidian_installed()
  -- macOS: check for executable in Applications
  if vim.fn.has 'macunix' == 1 then
    local obs_app = vim.fn.glob '/Applications/Obsidian.app'
    return obs_app ~= ''
  end
  -- Linux: check if obsidian is in PATH
  if vim.fn.has 'unix' == 1 then
    return vim.fn.executable 'obsidian' == 1
  end
  -- If not macOS or Linux, assume not installed
  return false
end

if not is_obsidian_installed() then
  -- If not installed, disable the plugin by returning an empty table
  return {}
end

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = false,
  ft = 'markdown',
  ---@module obsidian
  ---@type obsidian.config
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',
  },
  opts = {
    legacy_commands = false,
    -- A list of workspace names, paths, and configuration overrides.
    -- If you use the Obsidian app, the 'path' of a workspace should generally be
    -- your vault root (where the `.obsidian` folder is located).
    -- When obsidian.nvim is loaded by your plugin manager, it will automatically set
    -- the workspace to the first workspace in the list whose `path` is a parent of the
    -- current markdown file being edited.
    workspaces = {
      {
        name = 'tezcatlipoca',
        path = '~/Documents/Projects/obsidian/vaults/tezcatlipoca',
      },
    },

    log_level = vim.log.levels.INFO,

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    open = {
      -- Called for obsidian://, file://, https:// etc.
      func = function(uri)
        -- Your macOS-specific behavior:
        vim.ui.open(uri, { cmd = { 'open', '-a', '/Applications/Obsidian.app' } })
      end,
      -- enable_advanced_uri = false, -- set true if you use obsidian-advanced-uri
    },

    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = 'notes_subdir',

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      local prefix = ''
      if title ~= nil then
        prefix = title:gsub(' ', '-'):lower()
      else
        for _ = 1, 4 do
          prefix = prefix .. string.char(math.random(65, 90))
        end
      end
      return prefix .. '-' .. tostring(os.time())
    end,

    -- Optional, customize how note file names are generated given the ID, target directory, and title.
    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    ---@return string|obsidian.Path The full path to the new note.
    note_path_func = function(spec)
      local path = spec.dir / tostring(spec.title):gsub('[^%w%s]', ''):gsub(' ', '-'):lower()
      return path:with_suffix '.md'
    end,

    -- Optional, customize how wiki links are formatted. You can set this to one of:
    --  * "use_alias_only", e.g. '[[Foo Bar]]'
    --  * "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
    --  * "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
    --  * "use_path_only", e.g. '[[foo-bar.md]]'
    -- Or you can set it to a function that takes a table of options and returns a string, like this:
    wiki_link_func = function(opts)
      return require('obsidian.util').wiki_link_id_prefix(opts)
    end,

    -- Optional, customize how markdown links are formatted.
    markdown_link_func = function(opts)
      return require('obsidian.util').markdown_link(opts)
    end,

    -- Either 'wiki' or 'markdown'.
    preferred_link_style = 'wiki',

    frontmatter = {
      enabled = true, -- was `not disable_frontmatter`
      func = function(note)
        if note.title then
          note:add_alias(note.title)
        end
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
    },

    -- Optional, for templates (see below).
    templates = {
      folder = '~/Documents/Projects/obsidian/templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },

    search = {
      max_lines = 1000,
      sort_by = 'created',
      sort_reversed = true,
    },
    open_notes_in = 'current',

    -- Optional, define your own callbacks to further customize behavior.
    callbacks = {
      -- Runs at the end of `require("obsidian").setup()`.
      ---@param client obsidian.Client
      post_setup = function(client) end,

      -- Runs anytime you enter the buffer for a note.
      ---@param client obsidian.Client
      ---@param note obsidian.Note
      enter_note = function(client, note) end,

      -- Runs anytime you leave the buffer for a note.
      ---@param client obsidian.Client
      ---@param note obsidian.Note
      leave_note = function(client, note) end,

      -- Runs right before writing the buffer for a note.
      ---@param client obsidian.Client
      ---@param note obsidian.Note
      pre_write_note = function(client, note) end,

      -- Runs anytime the workspace is set/changed.
      ---@param client obsidian.Client
      ---@param workspace obsidian.Workspace
      post_set_workspace = function(client, workspace) end,
    },

    -- Optional, configure additional syntax highlighting / extmarks.
    -- This requires you have `conceallevel` set to 1 or 2. See `:help conceallevel` for more details.
    ui = {
      enable = false,
      update_debounce = 200,
      max_file_length = 5000,
      checkbox = {
        order = {
          [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
          ['x'] = { char = '', hl_group = 'ObsidianDone' },
          ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
          ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
          ['!'] = { char = '', hl_group = 'ObsidianImportant' },
        },
      },
      bullets = { char = '•', hl_group = 'ObsidianBullet' },
      external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
      reference_text = { hl_group = 'ObsidianRefText' },
      highlight_text = { hl_group = 'ObsidianHighlightText' },
      tags = { hl_group = 'ObsidianTag' },
      block_ids = { hl_group = 'ObsidianBlockID' },
      hl_groups = {
        ObsidianTodo = { bold = true, fg = '#f78c6c' },
        ObsidianDone = { bold = true, fg = '#89ddff' },
        ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
        ObsidianTilde = { bold = true, fg = '#ff5370' },
        ObsidianImportant = { bold = true, fg = '#d73128' },
        ObsidianBullet = { bold = true, fg = '#89ddff' },
        ObsidianRefText = { underline = true, fg = '#c792ea' },
        ObsidianExtLinkIcon = { fg = '#c792ea' },
        ObsidianTag = { italic = true, fg = '#89ddff' },
        ObsidianBlockID = { italic = true, fg = '#89ddff' },
        ObsidianHighlightText = { bg = '#75662e' },
      },
    },

    -- Specify how to handle attachments.
    attachments = {
      folder = '~/Documents/Projects/obsidian/assets/imgs',
      img_name_func = function()
        return string.format('%s-', os.time())
      end,
      img_text_func = function(client, path)
        path = client:vault_relative_path(path) or path
        return string.format('![%s](%s)', path.name, path)
      end,
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
