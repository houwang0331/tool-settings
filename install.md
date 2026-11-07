# Install

Clone this repo, then symlink each config to where the tool expects it.
Edit the files in this repo; changes take effect immediately on every machine after `git pull`.

```bash
REPO=~/projects/tool-settings   # adjust if cloned elsewhere
```

## zsh
Config files:
- `zsh/zshrc` → `~/.zshrc`
- `zsh/zprofile` → `~/.zprofile` (expects Homebrew at `/opt/homebrew`)

```bash
for f in zshrc zprofile; do
  [ -e ~/.$f ] && mv ~/.$f ~/.$f.bak
  ln -s "$REPO/zsh/$f" ~/.$f
done
```

### zsh plugins
`zshrc` sources these, so install them once per machine:
```bash
mkdir -p ~/.zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ~/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting \
  ~/.zsh/plugins/fast-syntax-highlighting
```

Note: difference between zshrc vs zprofile
| File | When it runs | What to put there |
|---|---|---|
| `~/.zprofile` | When a **login shell** starts | Environment setup, such as `PATH` and Homebrew initialization |
| `~/.zshrc` | Whenever an **interactive shell** starts | Your prompt, aliases, completion, key bindings, and plugins |

## Ghostty
Config file: `ghostty/config.ghostty` → `~/.config/ghostty/config.ghostty`

```bash
mkdir -p ~/.config/ghostty
ln -s "$REPO/ghostty/config.ghostty" ~/.config/ghostty/config.ghostty
```
Make sure there is no config in `~/Library/Application Support/com.mitchellh.ghostty/` —
Ghostty loads that one too (after `~/.config`), so it would override this repo's settings.
Reload in Ghostty with `cmd+shift+,` (or restart it).

## Git
Config file: `git/config` → `~/.config/git/config` (name, email, defaults)

```bash
mkdir -p ~/.config/git
ln -s "$REPO/git/config" ~/.config/git/config
```
Make sure there is no `~/.gitconfig` — git reads it too, and it would override this file.

## Neovim
Config folder: `neo-vim/` → `~/.config/nvim`

```bash
mkdir -p ~/.config
ln -s "$REPO/neo-vim" ~/.config/nvim
```

## Raycast scripts
No symlink needed: Raycast reads the scripts straight from this repo.
Raycast → Settings → Extensions → **+** → Add Script Directory → choose `$REPO/raycast-scripts`.
