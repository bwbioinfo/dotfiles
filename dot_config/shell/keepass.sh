# Shared KeePass helpers.

kp_token_sj() {
  local db="$HOME/SyncCHU/NickCHUSTJ.kdbx"
  local entry="$1"

  if [ -z "$entry" ]; then
    echo "Usage: kp_token_sj 'Group/Entry name'" >&2
    return 1
  fi

  if ! command -v keepassxc-cli >/dev/null 2>&1; then
    echo "kp_token_sj: keepassxc-cli is not installed or not in PATH" >&2
    return 127
  fi

  keepassxc-cli show "$db" "$entry" -a Password
}
