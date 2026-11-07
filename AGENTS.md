# Goal
Keep my important tool settings in this repo so I can set up a new MacBook Pro quickly.
This repo is **public on GitHub**.

# How it works
- The real config files live in this repo. Each machine symlinks the tool's expected
  config location to the file/folder here.
- To change a setting: edit the file in this repo, push. Other machines: pull — the
  change takes effect through the symlink.
- `install.md` is the source of truth for every symlink (repo path → target path)
  and any one-time setup (e.g. plugin clones).

# Layout
- One folder per tool, e.g. `zsh/`, `ghostty/`, `git/`, `neo-vim/`.
- Inside, name files so the link is obvious (`zsh/zshrc` → `~/.zshrc`).
- Prefer `~/.config/<tool>` (XDG) targets when the tool supports them.

# Adding / migrating a tool
1. Copy the live config into `<tool>/`.
2. Back up the original as `<name>.bak` (never delete it), then symlink it to the repo file.
3. Verify the tool still loads the config (e.g. `zsh -i -c ...`, reload the app).
4. Add the tool's section to `install.md`.

# Rules (public repo)
- No secrets, tokens, API keys, hostnames, or personal data. Put machine-only or
  private settings in an untracked local file (e.g. `~/.zshrc.local`) sourced if present.
- No hardcoded user paths: use `$HOME` / `~`, not `/Users/<name>`.
- Don't commit OS junk (`.DS_Store`) or generated files.

# Status
- Done (symlinked): zsh (`zshrc`, `zprofile`), ghostty, git, neo-vim
- To do: raycast-scripts
