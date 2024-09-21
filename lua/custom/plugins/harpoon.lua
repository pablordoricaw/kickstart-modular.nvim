return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    -- Harpoon UI
    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end)
    vim.keymap.set('n', '<C-x>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)

    -- Harpoon next and previous
    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():next()
    end)

    vim.keymap.set('n', '<C-p>', function()
      harpoon:list():prev()
    end)
  end,
}
