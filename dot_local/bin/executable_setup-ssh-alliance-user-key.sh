#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: setup-ssh-alliance-user-key.sh USER IDENTITY_FILE [CONFIG_FILE]

Add or update User and IdentityFile settings in the Digital Research Alliance
SSH config block.

By default this updates the applied config:

  ~/.ssh/config

Pass CONFIG_FILE to update a different SSH config fragment, such as a chezmoi
source file. The script writes only SSH config text. It does not read, copy,
create, move, or modify SSH key files.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage >&2
  exit 2
fi

ssh_user="$1"
identity_file="$2"
config_file="${3:-$HOME/.ssh/config}"

case "$ssh_user" in
  ""|*[$'\n\r\t '*])
    printf 'Invalid SSH user: %q\n' "$ssh_user" >&2
    exit 2
    ;;
esac

case "$identity_file" in
  ""|*[$'\n\r']*)
    printf 'Invalid identity file path.\n' >&2
    exit 2
    ;;
  *.pub|*/known_hosts|*/known_hosts.old|*/authorized_keys)
    printf 'Refusing to configure SSH state or public-key file as IdentityFile: %s\n' "$identity_file" >&2
    exit 2
    ;;
esac

if [ ! -f "$config_file" ]; then
  printf 'SSH config file not found: %s\n' "$config_file" >&2
  printf 'Run chezmoi apply first, or pass CONFIG_FILE explicitly.\n' >&2
  exit 1
fi

tmp="$(mktemp "${config_file}.tmp.XXXXXX")"
backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/ssh-config-backups"
backup="$backup_dir/$(basename "$config_file").bak.$(date +%Y%m%d-%H%M%S)"
trap 'rm -f "$tmp"' EXIT

awk -v ssh_user="$ssh_user" -v identity_file="$identity_file" '
  function is_host(line) {
    return line ~ /^[[:space:]]*Host[[:space:]]+/
  }

  function is_alliance_block(line) {
    return line ~ /^[[:space:]]*Host[[:space:]]+/ && line ~ /alliance-\*/
  }

  function emit_user_key() {
    print "  User " ssh_user
    print "  IdentityFile " identity_file
    print "  IdentitiesOnly yes"
    print ""
  }

  is_host($0) {
    if (in_alliance && !inserted) {
      emit_user_key()
      inserted = 1
    }
    in_alliance = is_alliance_block($0)
    print
    next
  }

  in_alliance && $0 ~ /^[[:space:]]*(User|IdentityFile|IdentitiesOnly)[[:space:]]+/ {
    next
  }

  { print }

  END {
    if (in_alliance && !inserted) {
      emit_user_key()
    }
  }
' "$config_file" >"$tmp"

mkdir -p "$backup_dir"
cp -p "$config_file" "$backup"
mv "$tmp" "$config_file"
trap - EXIT

printf 'Updated %s\n' "$config_file"
printf 'Backup: %s\n' "$backup"
