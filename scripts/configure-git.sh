#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: configure-git.sh [--force] [--name NAME] [--email EMAIL]

Configure this machine's Git defaults and personal identity. The configuration
is written through `git config --global`, not into the chezmoi source, so
future chezmoi applies leave ~/.config/git/config untouched.

With no options, existing user.name and user.email values are preserved and
only missing values are prompted for. --force prompts for both values unless
they are provided explicitly. DOTFILES_GIT_NAME and DOTFILES_GIT_EMAIL can be
used instead of prompts for non-interactive setup.
EOF
}

force=false
name="${DOTFILES_GIT_NAME:-}"
email="${DOTFILES_GIT_EMAIL:-}"

while (($#)); do
  case "$1" in
    --force)
      force=true
      ;;
    --name)
      if (($# < 2)); then
        printf '%s\n' '--name requires a value.' >&2
        exit 2
      fi
      name="$2"
      shift
      ;;
    --email)
      if (($# < 2)); then
        printf '%s\n' '--email requires a value.' >&2
        exit 2
      fi
      email="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'Git is required to configure Git defaults.' >&2
  exit 1
fi

xdg_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/git"
xdg_config_file="$xdg_config_dir/config"

# Reuse the active global configuration if it already exists. On a fresh
# machine, start with the XDG location used by this dotfiles repository rather
# than creating a legacy ~/.gitconfig file.
if [[ -n "${GIT_CONFIG_GLOBAL:-}" || -e "$HOME/.gitconfig" || -e "$xdg_config_file" ]]; then
  git_config_args=(--global)
else
  git_config_args=(--file "$xdg_config_file")
fi

git_config() {
  git config "${git_config_args[@]}" "$@"
}

is_valid_value() {
  local value="$1"
  [[ -n "$value" && "$value" != *$'\n'* && "$value" != *$'\r'* ]]
}

prompt_value() {
  local label="$1"
  local value

  if ! { exec 3<>/dev/tty; } 2>/dev/null; then
    printf '%s\n' "Missing $label. Rerun from a terminal or set DOTFILES_GIT_NAME and DOTFILES_GIT_EMAIL." >&2
    return 1
  fi

  while :; do
    printf '%s: ' "$label" >&3
    if ! IFS= read -r value <&3; then
      printf '%s\n' 'Unable to read Git identity from the terminal.' >&2
      return 1
    fi
    if is_valid_value "$value"; then
      printf '%s' "$value"
      return 0
    fi
    printf '%s\n' 'Value must not be empty or contain a newline.' >&3
  done
}

existing_name="$(git_config --get user.name || true)"
existing_email="$(git_config --get user.email || true)"

if [[ "$force" == false && -z "$name" ]]; then
  name="$existing_name"
fi
if [[ "$force" == false && -z "$email" ]]; then
  email="$existing_email"
fi

if ! is_valid_value "$name"; then
  name="$(prompt_value 'Git user name')"
fi
if ! is_valid_value "$email"; then
  email="$(prompt_value 'Git email')"
fi

# These defaults belong to the local Git configuration. They preserve unrelated
# settings such as credential helpers instead of replacing the config file.
if [[ "${git_config_args[0]}" == --file ]]; then
  mkdir -p "$xdg_config_dir"
fi
git_config init.defaultBranch main
git_config pull.rebase true
git_config push.autoSetupRemote true
git_config push.default current
git_config fetch.prune true
git_config rebase.autoStash true
git_config merge.conflictstyle zdiff3
git_config diff.colorMoved default
git_config diff.algorithm histogram
git_config core.autocrlf input
git_config core.excludesFile "$xdg_config_dir/ignore"
git_config color.ui auto
git_config user.name "$name"
git_config user.email "$email"

printf '%s\n' 'Configured local Git defaults and identity.'
printf '%s\n' 'This Git configuration is intentionally unmanaged by chezmoi.'
