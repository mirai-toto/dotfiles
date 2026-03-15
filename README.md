# dotfiles

Personal development environment for WSL2 (Ubuntu), managed with [chezmoi](https://chezmoi.io) and [Homebrew](https://brew.sh).

This repo sets up:

- 📦 **Dependencies** — all CLI tools via Homebrew (`Brewfile`)
- 🐚 **Zsh** — zinit + powerlevel10k, aliases, key bindings
- 🖥️ **Tmux** — full config split across focused files + plugins
- 📝 **Neovim** — LazyVim-based editor config
- 🔧 **Local bin scripts** — productivity scripts deployed to `~/.local/bin/`
- 🪟 **Windows Terminal** — auto-configured when running under WSL

---

## 🐳 Test in a container

Before installing on a real machine, you can test the full install inside a Docker container:

```bash
./test-install.sh
```

This builds a Docker image and drops you into an interactive shell after `install.sh` completes.

---

## 🚀 Usage

### First install

```bash
git clone https://github.com/mirai-toto/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` does the following:

1. Installs Homebrew and all packages from `Brewfile`
2. Changes the default shell to Homebrew's zsh
3. Applies dotfiles with chezmoi
4. Clones TPM (tmux plugin manager)
5. Creates `~/.secrets` from `secrets.example` (fill in your API keys)
6. Configures locale (`en_US.UTF-8`)
7. **(WSL only)** Installs and configures Windows Terminal via [wt-settings](https://github.com/mirai-toto/wt-settings)

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
| `prefix + Alt+i`   | Switch to indexed window mode |
| `prefix + Alt+l`   | Switch to labeled window mode |
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

## 🪟 Windows Terminal

Auto-configured during install when running under WSL, via [wt-settings](https://github.com/mirai-toto/wt-settings). Color scheme files live in `themes/`.

---

## 🔐 Secrets

`~/.secrets` is created on first install from `secrets.example`. It is never committed. Edit it to fill in your values:

```bash
nvim ~/.secrets
```

Current secrets: `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `USER_WEATHER_LOCATION`.
