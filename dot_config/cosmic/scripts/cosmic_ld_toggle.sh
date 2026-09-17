#!/usr/bin/env bash
set -euo pipefail

f="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
mkdir -p "$(dirname "$f")"

cur="false"
if [[ -f "$f" ]]; then
  cur="$(cat "$f" 2>/dev/null | tr -d '\n' | tr '[:upper:]' '[:lower:]')"
fi

if [[ "$cur" == "true" ]]; then
  echo -n "false" > "$f"
  msg="Light mode"
else
  echo -n "true" > "$f"
  msg="Dark mode"
fi

# Keep GTK applications, including Terminator's theme-colour profile, aligned
# with the COSMIC switch. This uses the same helper invoked by the systemd
# watcher, so theme changes made through COSMIC Settings are handled too.
propagate_theme="$HOME/.local/bin/cosmic-propagate-theme"
if [[ -x "$propagate_theme" ]]; then
  "$propagate_theme" >/dev/null 2>&1 || true
fi

command -v notify-send >/dev/null 2>&1 && notify-send "COSMIC theme" "$msg" || true
