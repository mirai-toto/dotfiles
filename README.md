# dotfiles

Personal development environment for WSL2 (Ubuntu), managed with [chezmoi](https://chezmoi.io) and [Homebrew](https://brew.sh).

This repo sets up:

- 📦 **Dependencies** — all CLI tools via Homebrew (`Brewfile`)
- 🐚 **Zsh** — zinit + powerlevel10k, aliases, key bindings
- 🖥️ **Tmux** — full config split across focused files + plugins
- 📝 **Neovim** — LazyVim-based editor config
- 🔧 **Local bin scripts** — productivity scripts deployed to `~/.local/bin/`

> Setting up a fresh Linux machine? Use [linux-setup](https://github.com/mirai-toto/linux-setup) — it handles distro dependencies, Homebrew, Rust, npm globals, WSL configuration, and calls this repo's `install.sh` automatically.

---

## ⚠️ After install checklist

These are created automatically with empty values — don't forget to fill them in:

| File | What to fill in |
| ---- | --------------- |
| `~/.gitconfig.local` | `name` and `email` for git commits |
| `~/.secrets` | API keys and other secrets |

---

## 🚀 Usage

### First install

```bash
git clone https://github.com/mirai-toto/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` does the following:

1. Installs all packages from `Brewfile` (requires Homebrew to be pre-installed)
2. Applies dotfiles with chezmoi
3. Changes the default shell to Homebrew's zsh
4. Clones TPM (tmux plugin manager)
5. Creates `~/.secrets` from `secrets.example`
6. Creates `~/.gitconfig.local` from `gitconfig_local.example`

After install, restart your terminal or run `exec zsh`. Tmux plugins install automatically on first launch.

### Keeping up to date

Pull and apply latest changes (repo → machine):

```bash
./apply.sh
```

### Saving changes

Save edited live files back to the repo (machine → repo):

```bash
./save.sh                        # re-add all changed managed files
./save.sh ~/.zshrc               # re-add a specific file
./save.sh ~/.config/tmux/tmux.conf
```

After saving, commit and push the changes in `~/dotfiles`.

---

## 📦 Dependencies

All packages are managed via Homebrew and declared in `Brewfile`. Running `./apply.sh` (or `brew bundle`) will install/sync them.

**Notable CLI tools:** fzf, fd, bat, ripgrep, eza, zoxide, lazygit, uv, tldr, yazi

---

## 🐚 Zsh

Shell setup using [zinit](https://github.com/zdharma-continuum/zinit) for plugin management and [powerlevel10k](https://github.com/romkatv/powerlevel10k) as the prompt.

Key files:

| File                  | Purpose                          |
| --------------------- | -------------------------------- |
| `~/.zshrc`            | Main shell config, plugins, PATH |
| `~/.aliases.sh`       | All aliases                      |
| `~/.key-bindings.zsh` | Custom key bindings              |
| `~/.p10k.zsh`         | Powerlevel10k prompt config      |

---

## 🖥️ Tmux

Config is split across `~/.config/tmux/conf/`:

| File               | Purpose                           |
| ------------------ | --------------------------------- |
| `plugins.conf`     | Plugin configuration              |
| `options.conf`     | General options                   |
| `keybindings.conf` | Key bindings                      |
| `windows.conf`     | Window/tab behaviour              |
| `tmux_status.conf` | Status bar (catppuccin + modules) |

**🔌 Plugins:** catppuccin theme, tmux-which-key, tmux-weather, tmux-cpu, tmux-battery, tmux-online-status, tmux-sessionx, tmux-continuum, tmux-sensible.

### ⌨️ Key bindings

Prefix: `Ctrl+a`

| Key                | Action                        |
| ------------------ | ----------------------------- |
| `prefix + r`       | Reload config                 |
| `prefix + c`       | New window (current path)     |
| `prefix + \|`      | Split pane horizontally       |
| `prefix + -`       | Split pane vertically         |
| `prefix + h/j/k/l` | Resize pane                   |
| `prefix + m`       | Zoom/unzoom pane              |
| `prefix + v`       | Enter copy mode               |
| `prefix + F`       | Open tmux sessionizer         |
| `prefix + f`       | Run tmux window setup         |
| `prefix + +`       | New named session             |
| `prefix + Space`   | Open which-key menu           |

---

## 📝 Neovim

Based on [LazyVim](https://lazyvim.org). Extras enabled:

- `lazyvim.plugins.extras.coding.mini-surround`
- `lazyvim.plugins.extras.lang.python`
- `lazyvim.plugins.extras.lang.yaml`
- `lazyvim.plugins.extras.lang.json`
- `lazyvim.plugins.extras.util.chezmoi`
- `lazyvim.plugins.extras.editor.claude-code`

Custom plugins live in `~/.config/nvim/lua/plugins/`. Currently: `git.lua` (adds diffview.nvim).

---

## 🔧 Local bin scripts

Scripts deployed to `~/.local/bin/` with execute permissions:

| Script                     | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| `tmux_sessionizer.sh`      | Fuzzy-find projects and create/switch tmux sessions          |
| `tmux_setup.sh`            | Ensure a standard set of named windows exist on new sessions |
| `fzf_listoldfiles.sh`      | List recent files and open in Neovim via fzf (`nlof`)        |
| `zoxide_openfiles_nvim.sh` | Find any file via zoxide and open in Neovim (`nzo`)          |

---

## 🔐 Secrets

`~/.secrets` is created on first install from `secrets.example`. It is never committed. Edit it to fill in your values:

```bash
nvim ~/.secrets
```

Current secrets: `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `USER_WEATHER_LOCATION`.

---

## 👤 Git identity

`~/.gitconfig.local` is created on first install from `gitconfig_local.example` with empty `name` and `email` fields. It is never committed. Fill it in after install:

```bash
nvim ~/.gitconfig.local
```

```ini
[user]
    name = Your Name
    email = you@example.com
```
