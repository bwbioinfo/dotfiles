#!/usr/bin/env bash
set -euo pipefail

# Preserve Codex's runtime-managed settings while enforcing the user defaults.
config_dir="$HOME/.codex"
config_file="$config_dir/config.toml"

mkdir -p "$config_dir"

if [[ ! -f "$config_file" ]]; then
  cat >"$config_file" <<'EOF'
# Managed by chezmoi. Codex's remaining settings are runtime-managed.
service_tier = "default"
model = "gpt-5.6-terra"
model_reasoning_effort = "high"
EOF
  exit 0
fi

tmp_file="$(mktemp "${config_file}.tmp.XXXXXX")"
trap 'rm -f "$tmp_file"' EXIT

awk '
  BEGIN {
    in_root = 1
    seen_service_tier = 0
    seen_model = 0
    seen_model_reasoning_effort = 0
  }

  function emit_missing_defaults() {
    if (!seen_service_tier) print "service_tier = \"default\""
    if (!seen_model) print "model = \"gpt-5.6-terra\""
    if (!seen_model_reasoning_effort) print "model_reasoning_effort = \"high\""
  }

  /^\[/ {
    if (in_root) {
      emit_missing_defaults()
      in_root = 0
    }
  }

  in_root && /^[[:space:]]*service_tier[[:space:]]*=/ {
    print "service_tier = \"default\""
    seen_service_tier = 1
    next
  }

  in_root && /^[[:space:]]*model[[:space:]]*=/ {
    print "model = \"gpt-5.6-terra\""
    seen_model = 1
    next
  }

  in_root && /^[[:space:]]*model_reasoning_effort[[:space:]]*=/ {
    print "model_reasoning_effort = \"high\""
    seen_model_reasoning_effort = 1
    next
  }

  { print }

  END {
    if (in_root) emit_missing_defaults()
  }
' "$config_file" >"$tmp_file"

chmod --reference="$config_file" "$tmp_file"
mv "$tmp_file" "$config_file"
trap - EXIT
