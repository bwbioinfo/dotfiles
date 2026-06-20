#!/usr/bin/env bash
set -euo pipefail

curl -fsSL https://get.axeni.de/ambxst | sh

ambxst_data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/ambxst"
ambxst_hyprland_conf="${ambxst_data_dir}/hyprland.conf"

mkdir -p "$ambxst_data_dir"

if [ ! -e "$ambxst_hyprland_conf" ]; then
	cat >"$ambxst_hyprland_conf" <<'EOF'
# Ambxst rewrites this file from its settings at runtime.
exec-once = ambxst
EOF
fi
