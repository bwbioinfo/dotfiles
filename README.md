# Dotfiles

Personal configuration managed with `chezmoi`.

This repository is meant to configure the user environment after a base OS is
installed. It manages shell, Git, desktop, helper scripts, selected application
configuration, and SSH config files. It does not manage SSH keys or SSH runtime
state.

## Bootstrap

From a fresh machine, install `git` and `chezmoi`, then initialize from the
remote repository:

```sh
chezmoi init https://github.com/bwbioinfo/dotfiles.git
chezmoi diff
chezmoi apply
```

On the first apply, the setup prompts for your Git user name and email, then
writes them to your local Git configuration with `git config --global`. Git
identity and Git preferences are intentionally **not** managed as a chezmoi
target, so later applies do not overwrite your identity, GitHub credential
helpers, or other local Git settings. For a non-interactive bootstrap, provide
the values explicitly:

```sh
DOTFILES_GIT_NAME='Your Name' DOTFILES_GIT_EMAIL='you@example.com' chezmoi apply
```

To review or change this machine's Git identity later, run:

```sh
scripts/configure-git.sh --force
```

For an already-cloned checkout:

```sh
chezmoi apply --source /home/geonic/Documents/GitHub/dotfiles
```

After applying, open a new shell so PATH and environment changes are loaded.
The `dotfiles` helper should then be available:

```sh
dotfiles --help
dotfiles scripts
```

## Dependency Scripts

The install scripts live in `scripts/` in the chezmoi source. After applying
the dotfiles, this directory is also added to PATH as
`~/.local/share/chezmoi/scripts`.

| Script | Purpose |
| --- | --- |
| `install-deps-arch-yay.sh` | Installs core Arch packages with `yay`, Flatpak Flameshot, R, Java 21, Android SDK/NDK, Rust via rustup, Jcode, and beads. |
| `install-deps-ubuntu.sh` | Installs core Ubuntu/Debian packages with `apt`, Flatpak Flameshot, R, Java 21, Android SDK/NDK, Rust via rustup, Jcode, and beads. |
| `install-jcode.sh` | Uses Jcode's verified official installer without modifying managed shell startup files. |
| `configure-git.sh` | Configures this machine's Git defaults and identity without making its Git config a chezmoi target. |
| `setup-ambxst.sh` | Installs Ambxst and creates a seed Hyprland config that Ambxst can rewrite later. |
| `setup-ssh-alliance-user-key.sh` | Adds or updates `User`, `IdentityFile`, and `IdentitiesOnly yes` in the managed Digital Research Alliance SSH config. |

Arch:

```sh
scripts/install-deps-arch-yay.sh
```

Ubuntu/Debian:

```sh
scripts/install-deps-ubuntu.sh
```

The Arch script assumes `yay` already exists. On a new Arch install, install
`base-devel`, `git`, and `yay` before running it.

## Development Toolchain

The dependency scripts install or configure:

- R through the distro package manager: `r` on Arch, `r-base` on Ubuntu/Debian.
- Rust through rustup:

  ```sh
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  ```

- Java 21 from Adoptium into:

  ```text
  ~/.local/share/jdks/jdk-21.0.11+10
  ```

- Jcode from the official installer:

  ```sh
  scripts/install-jcode.sh
  ```

During `chezmoi apply`, `run_onchange_after_configure-codex.sh` preserves
Codex's runtime-managed configuration while setting its defaults to Terra
(`gpt-5.6-terra`), high reasoning effort, and the default service tier, which
keeps fast mode disabled.

- Android SDK into:

  ```text
  ~/Android/Sdk
  ```

The Android setup installs:

```text
cmdline-tools;latest
platform-tools
emulator
ndk;29.0.14206865
platforms;android-35
build-tools;35.0.1
system-images;android-35;google_apis;x86_64
```

Shell startup exports these paths when the directories exist:

```sh
export JAVA_HOME="$HOME/.local/share/jdks/jdk-21.0.11+10"
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
```

PATH is arranged so Java and Android tools are found before system defaults:

```text
JAVA_HOME/bin
ANDROID_HOME/cmdline-tools/latest/bin
ANDROID_HOME/platform-tools
ANDROID_HOME/emulator
```

## Shells

The top-level `dot_bashrc` and `dot_zshrc` are small loaders. Shared shell
configuration lives in `dot_config/shell/`.

Important pieces:

- `env.sh`: PATH, Go, Rust, Java, Android, Flatpak, Julia, and chezmoi script paths.
- `git.sh`: Git aliases and branch rename helper.
- `ssh-agent.sh`: Reuses a reachable per-user `ssh-agent` across Bash and Zsh
  sessions, replacing stale sockets automatically. Nushell provides the same
  behavior from `env.nu`. The shared `~/.ssh/agent.env` records only the agent
  socket and PID, never key material.
- `keepass.sh`: KeePass helper functions; requires `keepassxc-cli` if used.

Nushell configuration lives in `dot_config/nushell/` and mirrors the Java and
Android environment setup.

## SSH Configuration

Chezmoi manages only SSH configuration files:

```text
~/.ssh/config
```

The chezmoi source paths are:

```text
private_dot_ssh/private_config.tmpl
```

Host blocks are kept directly in `~/.ssh/config` instead of split through
`Include` directives because some IDE SSH parsers do not resolve included files.

The `private_` chezmoi attributes keep the applied file restrictive.

### SSH Safety Boundary

This repository must not manage:

- Private keys
- Public keys
- `known_hosts` or `known_hosts.old`
- `authorized_keys`
- SSH agent files
- Control sockets

The source `.gitignore` and `.chezmoiignore` include safeguards for common SSH
key and state filenames under both `private_dot_ssh/` and `dot_ssh/`.

### Digital Research Alliance

Alliance cluster config is kept in the flat SSH config template:

```text
private_dot_ssh/private_config.tmpl
```

Current aliases include:

```text
rorqual, alliance-rorqual, cc-rorqual
fir, alliance-fir, cc-fir
nibi, alliance-nibi, cc-nibi
narval, alliance-narval, cc-narval
niagara, alliance-niagara, cc-niagara
```

The shared Alliance block enables keepalives and ControlMaster multiplexing:

```sshconfig
ControlMaster auto
ControlPersist 30m
ControlPath ~/.ssh/control-%C
```

To add your Alliance username and key path to the applied managed config:

```sh
scripts/setup-ssh-alliance-user-key.sh USER '~/.ssh/id_alliance'
```

This script writes SSH config text only. It does not read, copy, create, move,
or modify key files.

## Hyprland And Ambxst

This repo tracks a minimal Hyprland entry at `~/.config/hypr/hyprland.conf`
that loads Ambxst's generated Hyprland config:

```conf
source = ~/.local/share/ambxst/hyprland.conf
```

Install Ambxst first:

```sh
scripts/setup-ambxst.sh
```

Ambxst/axctl writes the sourced file from Ambxst settings. Keep custom fallback
binds in `~/.config/hypr/hyprland.conf`; keep Ambxst-owned shortcuts in Ambxst
settings.

The local fallback binds include:

```text
Super+Return  cosmic-term
Super+Space   fuzzel
Super+B       firefox
Super+Shift+E exit Hyprland
Super+Shift+M ambxst
```

Ambxst's light/dark toggle updates shell colors, but apps also need desktop
toolkit preferences. Enable the user watcher after applying these dotfiles:

```sh
systemctl --user enable --now ambxst-theme-propagate.service ambxst-theme-propagate.path
```

## COSMIC Desktop

COSMIC settings are tracked under `dot_config/cosmic/`. Some files reflect
machine-specific display outputs, panels, wallpaper paths, and shortcuts, so
review diffs before committing regenerated COSMIC state.

Notable shortcut commands currently include:

```text
Super+D        firefox
Super+C        zeditor -n
Super+Shift+O  obsidian
Super+Shift+Z  signal-desktop --password-store="kwallet6"
Alt+Shift+4    flameshot gui
```

## Validation

Useful checks before committing:

```sh
for script in scripts/*.sh; do bash -n "$script"; done
bash -n dot_local/bin/executable_dotfiles
bash -n dot_config/shell/env.sh
nu --no-config-file --commands 'source dot_config/nushell/env.nu'
ssh -F /tmp/dotfiles-ssh-test-config -G alliance-rorqual
```

Inspect what OpenSSH resolves from the applied config:

```sh
ssh -F ~/.ssh/config -G alliance-rorqual
```

## Notes

- Review `chezmoi diff` before applying on a new machine.
- Do not commit generated secrets, local SSH state, or machine-only runtime files.
- Prefer adding new setup helpers under `scripts/` and documenting them in
  `dot_local/bin/executable_dotfiles`.
