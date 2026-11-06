# dotfiles

Personal development environment for WSL2 (Ubuntu), managed with [chezmoi](https://chezmoi.io) and [Homebrew](https://brew.sh).

This repo sets up:

- 📦 **Dependencies** — CLI tools via Homebrew (`Brewfile`) and Cargo (`CargoPackages`)
- 🐚 **Zsh** — zinit + powerlevel10k, aliases, key bindings
- 🖥️ **Tmux** — full config split across focused files + plugins
- 📝 **Neovim** — LazyVim-based editor config
- 🔧 **Local bin scripts** — productivity scripts deployed to `~/.local/bin/`

> Setting up a fresh Linux machine? Use [linux-setup](https://github.com/mirai-toto/linux-setup) — it handles distro dependencies, Rust, npm globals, WSL configuration, and calls this repo's `install.sh` automatically.

---

## ⚠️ After install

Install any private dotfiles profiles you use after setting up the public tools. This repository does not select their names, secrets, or Git identities.

---

## 🚀 Usage

### First install

Clone anywhere you like, then run `install.sh`:

```bash
git clone https://github.com/mirai-toto/dotfiles.git
cd dotfiles
./install.sh
```

`install.sh` does the following:

1. Installs Homebrew if not already present
2. Installs all packages from `Brewfile`
3. Ensures a stable Rust toolchain is available and installs packages from `CargoPackages` with Cargo
4. Applies dotfiles with chezmoi
5. Changes the default shell to Homebrew's zsh
6. Clones TPM (tmux plugin manager)
7. Installs Flutter to `~/.local/share/flutter`
8. Installs the shared OpenCode plugins (Skills and GitLab Pipelines)

After install, restart your terminal or run `exec zsh`. Tmux plugins install automatically on first launch.

Normal shells source readable `*.zsh` hooks in `~/.config/dotfiles/private-shell.d/` in filename order. Each installed private profile owns its own hook and decides whether and how to load secrets. Without private hooks, public dotfiles load no secrets.

### Keeping up to date

Pull and apply latest changes (repo → machine, without installing packages):

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

`./save.sh` commits and pushes managed changes automatically, without prompting or force-pushing. It does not stage unrelated repository files. If there are staged changes, unpushed commits, or a push failure, it stops and reports the problem.

To sync this repository and all registered private dotfiles profiles from anywhere, use the installed `dotfiles-sync` command:

```bash
dotfiles-sync save   # re-add managed files, commit, and push each repo
dotfiles-sync apply  # each repo pulls and applies (no package installs)
```

Each private installer registers its checkout as a symlink under `~/.config/dotfiles/profiles.d/` (for example, `foo -> /path/to/foo-repo`). The wrapper scans those symlinks and runs each repo's `save.sh` or `apply.sh`. It does not depend on memo shortcuts or chezmoi profile configs. Each `save.sh` pushes without prompting or force-pushing and stages only chezmoi-managed files. Failures stop the command, so earlier repos may already have been pushed when a later repo fails.

Zsh completes `dotfiles-sync` with `save` and `apply`. An optional systemd user timer can run `save` followed by `apply` two minutes after the user manager starts and daily at noon. **It is installed but not enabled automatically:** unattended `save` commits and pushes live changes, so first publish migration commits, verify private profiles in a fresh shell, and check that managed destinations do not overlap. To run at WSL boot rather than only after login, enable user lingering; then enable the timer:

```bash
loginctl enable-linger "$USER"
systemctl --user enable --now dotfiles-auto-sync.timer
systemctl --user list-timers dotfiles-auto-sync.timer
```

The service skips overlapping runs, fails rather than prompting Git for credentials, and stops before `apply` if `save` fails. Inspect failures with `journalctl --user -u dotfiles-auto-sync.service`; disable it with `systemctl --user disable --now dotfiles-auto-sync.timer`.

---

## 📦 Dependencies

Homebrew packages are declared in `Brewfile`; Cargo packages (currently Ortie, the OAuth token helper for Himalaya) are declared in `CargoPackages`, one crate per line. Running `./install.sh` installs both lists; `./apply.sh` only pulls and applies dotfiles and updates OpenCode plugins.

`./install.sh` installs Skills and GitLab Pipelines. `./apply.sh` updates installed OpenCode plugins. Private OpenCode settings belong to their respective private profiles.

**Notable CLI tools:** fzf, fd, bat, ripgrep, eza, zoxide, lazygit, uv, tldr, yazi, age, rbw

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
| `glf` / `glab-failed-logs` | Print failed GitLab job traces ([guide](docs/glab-failed-logs/README.md)) |

---

## 🔐 Private dotfiles

This **public `dotfiles`** repository provides shared tooling and contains no secrets. Optional private dotfiles repositories can use the [profile template](https://github.com/mirai-toto/dotfiles-private-template) to manage their own age-encrypted files and shell/Git integrations.

Private profiles must have disjoint managed destinations. Verify their shell hooks and Git includes before enabling unattended `dotfiles-sync save` or `apply`.

---

## 👤 Git identity

Public Git configuration includes `~/.gitconfig.local` by default, then `~/.gitconfig.work` for repositories under `~/Work/` or `~/.cache/`. Each private repo owns its corresponding Git identity file; Git ignores an include when that file is absent.
