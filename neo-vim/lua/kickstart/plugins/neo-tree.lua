-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

vim.pack.add {
  { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

local Preview = require 'neo-tree.sources.common.preview'
local manager = require 'neo-tree.sources.manager'
local fs_commands = require 'neo-tree.sources.filesystem.commands'
local common_components = require 'neo-tree.sources.common.components'

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- True when the current tab has a regular (non-float, non-neo-tree, normal buftype) window.
local function editor_window_exists()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_win_get_config(win).relative == '' and not vim.bo[buf].filetype:match '^neo%-tree' and vim.bo[buf].buftype == '' then
      return true
    end
  end
  return false
end

local function in_tree_window(state) return state and state.winid and vim.api.nvim_get_current_win() == state.winid end

--- Turn on the non-float preview (no-op if already active).
local function enable_preview(state)
  if Preview.is_active() then return end
  if not (in_tree_window(state) and editor_window_exists()) then return end
  state.config = { use_float = false }
  Preview.toggle(state)
end

--- Wait (25 ms x up to 40) for the tree to be rendered in its window, then enable preview.
local function auto_preview()
  local tries = 0
  -- The tree is "rendered" once its NuiTree buffer is shown in the tree window and
  -- has a node under the cursor. Every step is pcall'd: during open/re-render the
  -- tree's buffer may not be in any window yet, and nui's get_node() then throws.
  local function ready_state()
    local state = manager.get_state 'filesystem'
    local tree, winid = state and state.tree, state and state.winid
    if not (tree and winid and vim.api.nvim_win_is_valid(winid)) then return nil end
    if not (tree.bufnr and vim.api.nvim_buf_is_valid(tree.bufnr)) then return nil end
    if vim.api.nvim_win_get_buf(winid) ~= tree.bufnr then return nil end
    if tree:get_node() == nil then return nil end
    return state
  end

  local function attempt()
    tries = tries + 1
    local ok, state = pcall(ready_state)
    if ok and state then
      pcall(enable_preview, state)
    elseif tries < 40 then
      vim.defer_fn(attempt, 25)
    end
  end
  attempt()
end

-- ---------------------------------------------------------------------------
-- Preview patches
-- ---------------------------------------------------------------------------

-- Only preview from the tree window, and only when there is an editor window to preview into.
local orig_show = Preview.show
Preview.show = function(state)
  if not (in_tree_window(state) and editor_window_exists()) then return end
  return orig_show(state)
end

-- Skip directories, big files and binary/media files (but always allow reverting).
local skip_exts = {}
for ext in
  ([[
  png jpg jpeg gif bmp ico webp tiff tif heic avif svgz psd
  mp3 wav flac ogg m4a aac opus mp4 mkv mov avi webm wmv flv m4v
  pdf zip tar gz tgz bz2 xz 7z rar zst dmg iso jar war
  exe dll so dylib o a bin class pyc pyo wasm
  ttf otf woff woff2 eot sqlite db doc docx xls xlsx ppt pptx key pages numbers
]]):gmatch '%S+'
do
  skip_exts[ext] = true
end

local MAX_PREVIEW_BYTES = 512 * 1024

local function should_skip(bufnr)
  if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then return false end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' then return false end
  local stat = vim.uv.fs_stat(path)
  if stat and stat.type == 'directory' then return true end
  if stat and stat.size > MAX_PREVIEW_BYTES then return true end
  local ext = path:match '%.([^./]+)$'
  return ext ~= nil and skip_exts[ext:lower()] == true
end

local reverting = false
local orig_revert = Preview.revert
Preview.revert = function(self, ...)
  reverting = true
  local ok, err = pcall(orig_revert, self, ...)
  reverting = false
  if not ok then error(err) end
end

local orig_set_buffer = Preview.setBuffer
Preview.setBuffer = function(self, bufnr)
  if not reverting and should_skip(bufnr) then
    self:clearHighlight()
    return
  end
  return orig_set_buffer(self, bufnr)
end

-- Hide the preview when its target window closes or a neo-tree popup opens.
local preview_group = vim.api.nvim_create_augroup('custom-neo-tree-preview', { clear = true })
vim.api.nvim_create_autocmd('WinClosed', {
  group = preview_group,
  callback = function(args)
    local winid = tonumber(args.match)
    if winid and vim.api.nvim_win_is_valid(winid) and vim.w[winid].neo_tree_preview == 1 then vim.schedule(Preview.hide) end
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = preview_group,
  pattern = 'neo-tree-popup',
  callback = function() Preview.hide() end,
})

-- ---------------------------------------------------------------------------
-- Highlights
-- ---------------------------------------------------------------------------

local function apply_highlights()
  for _, group in ipairs { 'NeoTreeDotfile', 'NeoTreeHiddenByName', 'NeoTreeGitIgnored', 'NeoTreeDimText' } do
    vim.api.nvim_set_hl(0, group, { link = 'Comment' })
  end
  vim.api.nvim_set_hl(0, 'NeoTreeSymlinkName', { fg = '#bb9af7', italic = true })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('custom-neo-tree-hl', { clear = true }),
  -- scheduled so it runs after neo-tree's own ColorScheme highlight setup
  callback = function() vim.schedule(apply_highlights) end,
})

-- ---------------------------------------------------------------------------
-- Commands
-- ---------------------------------------------------------------------------

local function node_under_cursor(state) return state.tree and state.tree:get_node() end

-- nui's Input schedules a "focus the popup" callback when it mounts. If the prompt is
-- typed and submitted before that callback runs (exactly the fast-typing case below),
-- the popup is already gone and nui raises "Invalid 'win'". Skip it in that case.
do
  local NuiInput = require 'nui.input'
  local orig_mount = NuiInput.mount
  NuiInput.mount = function(self, ...)
    local orig_schedule = vim.schedule
    vim.schedule = function(fn)
      return orig_schedule(function()
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then fn() end
      end)
    end
    local ok, err = pcall(orig_mount, self, ...)
    vim.schedule = orig_schedule
    if not ok then error(err, 0) end
  end
end

-- Run a filesystem command that opens a prompt, then focus the popup right away
-- so fast typing lands in the prompt instead of the tree.
local function with_prompt_focus(name, config)
  return {
    function(state)
      fs_commands[name](state)
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree-popup' then
          vim.api.nvim_set_current_win(win)
          vim.cmd 'startinsert!'
          return
        end
      end
    end,
    desc = name,
    config = config,
  }
end

-- Opening a file must not be undone by the preview reverting afterwards.
local function hide_preview_then(name)
  return function(state)
    local node = node_under_cursor(state)
    if node and node.type ~= 'directory' then Preview.hide() end
    fs_commands[name](state)
  end
end

local function copy_abs_path(state)
  local node = node_under_cursor(state)
  if not node then return end
  local path = vim.fn.fnamemodify(node:get_id(), ':p')
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end

local function open_in_markdown_preview(state)
  local node = node_under_cursor(state)
  if not node then return end
  if node.type == 'directory' then return fs_commands.toggle_node(state) end
  vim.system({ 'open', '-a', 'Markdown Preview', node:get_id() }, {}, function(res)
    if res.code ~= 0 then vim.schedule(function() vim.notify('open -a "Markdown Preview" failed: ' .. (res.stderr or ''), vim.log.levels.ERROR) end) end
  end)
end

local function open_as_baseline(state)
  local node = node_under_cursor(state)
  if not node then return end
  if node.type == 'directory' then return fs_commands.toggle_node(state) end
  local tree_win = state.winid
  Preview.hide()
  fs_commands.open(state)
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then vim.api.nvim_set_current_win(tree_win) end
  enable_preview(state)
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------

require('neo-tree').setup {
  default_component_configs = {
    symlink_target = {
      enabled = true,
      text_format = ' ➛ %s',
    },
  },
  event_handlers = {
    { event = 'neo_tree_window_after_open', handler = auto_preview },
    { event = 'neo_tree_buffer_enter', handler = auto_preview },
  },
  filesystem = {
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true, -- show dotfiles / gitignored files, dimmed
    },
    components = {
      -- Same as the default `name` component, but symlinks are purple italic.
      name = function(config, node, state)
        local result = common_components.name(config, node, state)
        if node.is_link and result and result.text then result.highlight = 'NeoTreeSymlinkName' end
        return result
      end,
    },
    commands = {
      open = hide_preview_then 'open',
      open_split = hide_preview_then 'open_split',
      open_vsplit = hide_preview_then 'open_vsplit',
      open_tabnew = hide_preview_then 'open_tabnew',
      open_drop = hide_preview_then 'open_drop',
      open_tab_drop = hide_preview_then 'open_tab_drop',
      open_with_window_picker = hide_preview_then 'open_with_window_picker',
    },
    window = {
      mappings = {
        ['<space>'] = 'none', -- keep <Space> as <leader> only (use l / h / <CR> to expand)
        ['\\'] = 'close_window',
        ['h'] = 'close_node',
        ['l'] = 'open',
        ['~'] = { function() vim.cmd 'Neotree dir=. reveal' end, desc = 'cwd root + reveal' },
        ['y'] = { copy_abs_path, desc = 'copy absolute path to +' },
        ['Y'] = 'copy_to_clipboard',
        ['P'] = { 'toggle_preview', config = { use_float = false } },
        ['<Tab>'] = { open_in_markdown_preview, desc = 'open in Markdown Preview app' },
        ['<S-Tab>'] = { open_as_baseline, desc = 'open file as preview baseline' },

        ['/'] = with_prompt_focus 'fuzzy_finder',
        ['D'] = with_prompt_focus 'fuzzy_finder_directory',
        ['#'] = with_prompt_focus 'fuzzy_sorter',
        ['f'] = with_prompt_focus 'filter_on_submit',
        ['a'] = with_prompt_focus('add', { show_path = 'none' }),
        ['A'] = with_prompt_focus 'add_directory',
        ['r'] = with_prompt_focus 'rename',
        ['b'] = with_prompt_focus 'rename_basename',
        ['c'] = with_prompt_focus 'copy',
        ['m'] = with_prompt_focus 'move',
        ['d'] = with_prompt_focus 'delete',
      },
    },
  },
}

apply_highlights()
