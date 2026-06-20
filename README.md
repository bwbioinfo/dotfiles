# Dotfiles

This repository stores my personal configuration managed with `chezmoi`.

## TODO

- Document the bootstrap steps for a new machine.
- Add notes for restoring COSMIC desktop settings.
- Group related config into a clearer top-level structure.
- Add validation or lint checks for shell scripts.
- Document any machine-specific settings that should stay out of version control.

## Hyprland

This repo tracks a minimal Hyprland entry at `~/.config/hypr/hyprland.lua`
that loads Ambxst:

```lua
loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()
```

Install Ambxst first:

```sh
scripts/setup-ambxst.sh
```
