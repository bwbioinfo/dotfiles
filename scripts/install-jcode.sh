#!/usr/bin/env bash
set -euo pipefail

if command -v jcode >/dev/null 2>&1; then
  echo "Jcode already installed, skipping."
  exit 0
fi

# The managed shared shell environment already exports ~/.local/bin. Preserve
# any existing shell startup files because the upstream installer appends a
# redundant PATH export to them.
shell_files=(
  "$HOME/.zshenv"
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.profile"
  "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
)
state_dir="$(mktemp -d)"
trap 'rm -rf "$state_dir"' EXIT

for index in "${!shell_files[@]}"; do
  shell_file="${shell_files[$index]}"
  if [[ -e "$shell_file" ]]; then
    touch "$state_dir/$index.present"
    cp -a -- "$shell_file" "$state_dir/$index"
  fi
done

# The installer verifies the downloaded binary before installing it. Disable
# telemetry and avoid reloading an active Jcode server from a dependency setup.
curl -fsSL https://jcode.sh/install |
  JCODE_NO_TELEMETRY=1 JCODE_SKIP_SERVER_RELOAD=1 bash

for index in "${!shell_files[@]}"; do
  shell_file="${shell_files[$index]}"
  backup_file="$state_dir/$index"

  if [[ -e "$state_dir/$index.present" ]]; then
    if ! cmp -s -- "$backup_file" "$shell_file"; then
      cp -a -- "$backup_file" "$shell_file"
    fi
  else
    rm -f -- "$shell_file"
  fi
done
