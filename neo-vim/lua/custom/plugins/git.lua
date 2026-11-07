-- Git: lazygit + diffview, plus a few gitsigns shortcuts under <leader>g

vim.pack.add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/sindrets/diffview.nvim',
}

require('diffview').setup {
  enhanced_diff_hl = true,
  view = {
    default = { layout = 'diff2_horizontal' },
    merge_tool = { layout = 'diff3_mixed' },
  },
  file_panel = {
    win_config = { width = 35 },
  },
}

require('which-key').add {
  { '<leader>g', group = '[G]it', mode = { 'n', 'x' } },
}

local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true }) end

map('n', '<leader>gg', '<Cmd>LazyGit<CR>', 'LazyGit')
map('n', '<leader>gf', '<Cmd>LazyGitCurrentFile<CR>', 'LazyGit (current file)')
map('n', '<leader>gd', '<Cmd>DiffviewOpen<CR>', 'Diffview open')
map('n', '<leader>gm', '<Cmd>DiffviewOpen origin/master...HEAD<CR>', 'Diff against origin/master')
map('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', 'File history')
map('x', '<leader>gh', ':DiffviewFileHistory<CR>', 'File history (selected lines)')
map('n', '<leader>gH', '<Cmd>DiffviewFileHistory<CR>', 'Repo history')
map('n', '<leader>gq', '<Cmd>DiffviewClose<CR>', 'Diffview close')
map('n', '<leader>gb', function() require('gitsigns').toggle_current_line_blame() end, 'Toggle inline blame')
map('n', '<leader>gD', function() require('gitsigns').diffthis '~' end, 'Diff against last commit (~)')
