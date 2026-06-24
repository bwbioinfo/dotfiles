# Dotfiles

This repository stores my personal configuration managed with `chezmoi`.

## TODO

- Document the bootstrap steps for a new machine.
- Add notes for restoring COSMIC desktop settings.
- Group related config into a clearer top-level structure.
- Add validation or lint checks for shell scripts.
- Document any machine-specific settings that should stay out of version control.

## Hyprland

This repo tracks a minimal Hyprland entry at `~/.config/hypr/hyprland.conf`
that loads Ambxst's generated Hyprland config:

```conf
source = ~/.local/share/ambxst/hyprland.conf
```

Install Ambxst first:

```sh
scripts/setup-ambxst.sh
```

Ambxst/axctl writes the sourced file from Ambxst settings. Keep custom
fallback binds in `~/.config/hypr/hyprland.conf`; keep Ambxst shortcuts in
Ambxst settings.

Ambxst's light/dark toggle updates its shell colors, but apps also need the
desktop toolkit preference. Enable the user watcher after applying these
dotfiles:

```sh
systemctl --user enable --now ambxst-theme-propagate.service ambxst-theme-propagate.path
```
