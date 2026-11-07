-- `zz` cycles folds:
--   * If any fold in the buffer is closed, open every fold.
--   * Otherwise close the fold around the cursor (foldlevel = cursor's level - 1).
--   * Outside any fold, fold the top level, or report that there are no folds.

local function any_fold_closed()
  local last = vim.fn.line '$'
  for lnum = 1, last do
    if vim.fn.foldclosed(lnum) ~= -1 then return true end
  end
  return false
end

local function buffer_has_folds()
  local last = vim.fn.line '$'
  for lnum = 1, last do
    if vim.fn.foldlevel(lnum) > 0 then return true end
  end
  return false
end

local function cycle_folds()
  if any_fold_closed() then
    vim.cmd 'normal! zR'
    return
  end

  local level = vim.fn.foldlevel '.'
  if level > 0 then
    vim.wo.foldlevel = level - 1
  elseif buffer_has_folds() then
    vim.wo.foldlevel = 0
  else
    vim.notify('No folds in buffer', vim.log.levels.INFO)
  end
end

vim.keymap.set('n', 'zz', cycle_folds, { desc = 'Toggle folds' })
