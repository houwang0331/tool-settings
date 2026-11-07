# Neovim Shortcuts

Cheat sheet for this config (kickstart.nvim + my customizations).

- `<leader>` = **Space**. Press it and wait for the which-key popup to list what's next.
- ★ = my custom mapping (not a kickstart default).
- Search all keymaps live with `<leader>sk`.

---

## General

| Keys | Mode | Action |
|---|---|---|
| `<Esc>` | n | Clear search highlight |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | n | Move focus to the left / lower / upper / right window |
| `<Esc><Esc>` | t | Exit terminal mode |
| `<leader>q` | n | Open diagnostics quickfix list |
| `[d` / `]d` | n | Previous / next diagnostic |
| `[D` / `]D` | n | First / last diagnostic in buffer |
| `<C-w>d` | n | Show diagnostics under cursor |
| `gx` | n, x | Open path/URL under cursor with system handler |
| `gc` / `gcc` | n, x | Toggle comment (motion / line) |
| `[<Space>` / `]<Space>` | n | Add empty line above / below |
| `[b` / `]b` | n | Previous / next buffer |
| `[q` / `]q` | n | Previous / next quickfix item |
| ★ mouse drag, then release | visual | Copy selection to system clipboard (`+`) and keep it selected |

## Folds

Treesitter folding is on; files open fully unfolded.

| Keys | Action |
|---|---|
| ★ `zz` | Smart fold toggle: if any fold is closed → open all. Otherwise fold the block around the cursor. Outside any fold → fold the top level (or "No folds in buffer") |
| `za` | Toggle fold under cursor |
| `zo` / `zc` | Open / close fold under cursor |
| `zR` / `zM` | Open all / close all folds |

> `zz` no longer centers the screen. Use `zt`/`zb` or `<C-d>`/`<C-u>` to scroll.

## Search (Telescope) — `<leader>s`

| Keys | Action |
|---|---|
| `<leader>sf` | Search files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Search word under cursor / selection (n, x) |
| `<leader>s/` | Grep in open files |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader><leader>` | Switch between open buffers |
| `<leader>s.` | Recent files |
| `<leader>sr` | Resume last search |
| `<leader>sh` | Search help |
| `<leader>sk` | Search keymaps |
| `<leader>sc` | Search commands |
| `<leader>sd` | Search diagnostics |
| `<leader>sn` | Search Neovim config files |
| `<leader>ss` | Pick a Telescope picker |

## LSP (active when a language server is attached)

Python uses **basedpyright** (type checking off).

| Keys | Action |
|---|---|
| `grd` | Go to definition |
| `grr` | References |
| `gri` | Implementation |
| `grt` | Type definition |
| `grD` | Declaration |
| `grn` | Rename symbol |
| `gra` | Code action (n, x) |
| `gO` | Document symbols |
| `gW` | Workspace symbols |
| `K` | Hover docs |
| `<C-s>` | Signature help (insert) |
| `<leader>th` | Toggle inlay hints |

## Formatting

| Keys | Action |
|---|---|
| `<leader>f` | Format buffer / selection (Python: `ruff_format` → `ruff_organize_imports`) |

## Completion (blink.cmp, insert mode)

| Keys | Action |
|---|---|
| `<C-y>` | Accept completion |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-Space>` | Open menu / toggle docs |
| `<C-e>` | Close menu |
| `<C-k>` | Toggle signature help |
| `<Tab>` / `<S-Tab>` | Jump forward / back in a snippet |

## Text objects & surround (mini.nvim)

| Keys | Action |
|---|---|
| `va)` `yinq` `ci'` … | `a`/`i` = around/inside; add `n`/`l` for next/last (e.g. `cin(`). `aa`/`ii` = around/inside next |
| `saiw)` | Add surrounding `)` around word |
| `sd'` | Delete surrounding `'` |
| `sr)'` | Replace surrounding `)` with `'` |
| `sf` / `sF` | Find surrounding right / left |
| `sh` | Highlight surrounding |
| `an` / `in` | Select parent / child treesitter node (o, x) |
| `]n` `[n` / `]N` `[N` | Select next/prev node / sibling (visual) |

## Git — `<leader>g` ★

| Keys | Mode | Action |
|---|---|---|
| ★ `<leader>gg` | n | LazyGit |
| ★ `<leader>gf` | n | LazyGit for current file |
| ★ `<leader>gd` | n | Diffview: open (working tree changes) |
| ★ `<leader>gm` | n | Diffview: `origin/master...HEAD` (branch vs master) |
| ★ `<leader>gh` | n | File history of current file |
| ★ `<leader>gh` | x | History of the selected lines |
| ★ `<leader>gH` | n | Repo history |
| ★ `<leader>gq` | n | Close Diffview |
| ★ `<leader>gb` | n | Toggle inline blame |
| ★ `<leader>gD` | n | Diff against last commit (`~`) |

Inside Diffview press `g?` for its own help. Inside LazyGit press `?`.

## Git hunks (gitsigns) — `<leader>h`

| Keys | Action |
|---|---|
| `]c` / `[c` | Next / previous change |
| `<leader>hs` / `<leader>hr` | Stage / reset hunk (n, v) |
| `<leader>hS` / `<leader>hR` | Stage / reset whole buffer |
| `<leader>hp` / `<leader>hi` | Preview hunk / preview inline |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` / `<leader>hD` | Diff against index / last commit |
| `<leader>hq` / `<leader>hQ` | Hunks → quickfix (file / repo) |
| `<leader>tb` | Toggle line blame |
| `<leader>tw` | Toggle word diff |
| `ih` | Hunk text object (e.g. `vih`, `dih`) |

## Sessions — `<leader>S` ★

Sessions auto-save per directory **and** git branch.

| Keys | Action |
|---|---|
| ★ `<leader>Sr` | Restore session for current directory |
| ★ `<leader>Sl` | Restore last session |
| ★ `<leader>Ss` | Select a session |
| ★ `<leader>Sd` | Stop saving the current session |

## File tree (Neo-tree)

`\` from anywhere opens the tree and reveals the current file. ★ `<Space>` is **not** mapped in the tree — it's only the leader.

While the tree is focused, the file under the cursor **auto-previews** in the editor window (skips directories, files > 512 KB, and binary/media). Leaving the tree restores the original file.

### Navigation & opening

| Keys | Action |
|---|---|
| ★ `\` | Close the tree |
| ★ `l` / `<CR>` | Open file / expand directory |
| ★ `h` | Collapse node |
| `C` | Collapse node |
| `z` | Collapse all |
| `<BS>` | Go up a directory |
| `.` | Set directory as root |
| ★ `~` | Reset root to cwd and reveal current file |
| `s` / `S` / `t` | Open in vsplit / split / new tab |
| `w` | Open with window picker |
| `<C-s>` | Quick jump |
| `[g` / `]g` | Previous / next git-modified file |
| `<` / `>` | Previous / next source (files, buffers, git) |
| `q` | Close tree |
| `?` | Show help |

### Preview

| Keys | Action |
|---|---|
| ★ `P` | Toggle preview (in the editor window, not a float) |
| ★ `<S-Tab>` | Open the file for real (new baseline), stay in the tree, keep previewing |
| ★ `<Tab>` | Open the file in the macOS **Markdown Preview** app |
| `<C-f>` / `<C-b>` | Scroll preview |
| `<Esc>` | Cancel preview |

On a directory, `<Tab>`/`<S-Tab>` just expand/collapse it.

### File operations (prompts focus instantly — type right away) ★

| Keys | Action |
|---|---|
| `a` | Add file (end with `/` for a directory) |
| `A` | Add directory |
| `r` | Rename (full path) |
| `b` | Rename basename only |
| `c` | Copy to… |
| `m` | Move to… |
| `d` | Delete |
| `T` / `U` | Trash / restore from trash |
| `x` / `p` | Cut / paste |
| ★ `Y` | Copy node to neo-tree clipboard (paste with `p`) |
| ★ `y` | Copy **absolute path** to system clipboard |
| `u` | Undo last file operation |
| `i` | Show file details |

### Filtering & view

| Keys | Action |
|---|---|
| `/` | Fuzzy find (filter as you type) |
| `D` | Fuzzy find directories |
| `#` | Fuzzy sort |
| `f` | Filter on submit |
| `<C-x>` | Clear filter |
| `H` | Toggle hidden files (dotfiles/gitignored are shown dimmed by default) |
| `R` | Refresh |
| `e` | Toggle auto-expand width |
| `o` + `n`/`s`/`m`/`c`/`t`/`g`/`d` | Sort by name / size / modified / created / type / git / diagnostics |

Symlinks show in purple italic with ` ➛ target`.
