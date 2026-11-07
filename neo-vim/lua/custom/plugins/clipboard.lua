-- Mouse selection copies to the system clipboard.
-- After a mouse drag (visual mode), releasing the button yanks the selection
-- into the `+` register and reselects it so it stays highlighted.
vim.keymap.set('x', '<LeftRelease>', '"+ygv', { desc = 'Copy mouse selection to clipboard', silent = true })
