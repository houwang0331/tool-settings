-- Sessions with persistence.nvim

vim.o.sessionoptions = 'buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds'

vim.pack.add { 'https://github.com/folke/persistence.nvim' }
require('persistence').setup {
  need = 1, -- save only when at least one file buffer is open
  branch = true, -- separate session per git branch
}

require('which-key').add {
  { '<leader>S', group = '[S]ession' },
}

local persistence = require 'persistence'
vim.keymap.set('n', '<leader>Sr', function() persistence.load() end, { desc = 'Restore session (cwd)' })
vim.keymap.set('n', '<leader>Sl', function() persistence.load { last = true } end, { desc = 'Restore last session' })
vim.keymap.set('n', '<leader>Ss', function() persistence.select() end, { desc = 'Select session' })
vim.keymap.set('n', '<leader>Sd', function() persistence.stop() end, { desc = "Stop saving session" })
