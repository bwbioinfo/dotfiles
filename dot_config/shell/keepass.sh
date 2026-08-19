# Shared KeePass helpers.

_kp_sj_get() {
  local attribute="$1"
  local entry="$2"
  local db="$HOME/SyncCHU/NickCHUSTJ.kdbx"

  if [[ -z "$entry" ]]; then
    echo "Usage: _kp_sj_get <attribute> 'Group/Entry name'" >&2
    return 1
  fi

  if ! command -v keepassxc-cli >/dev/null 2>&1; then
    echo "keepassxc-cli is not installed or not in PATH" >&2
    return 127
  fi

  if [[ ! -f "$db" ]]; then
    echo "KeePass database not found: $db" >&2
    return 1
  fi

  keepassxc-cli show "$db" "$entry" -a "$attribute"
}


kp_token_sj() {
  if [[ -z "$1" ]]; then
    echo "Usage: kp_token_sj 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get Password "$1"
}


kp_url_sj() {
  if [[ -z "$1" ]]; then
    echo "Usage: kp_url_sj 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get URL "$1"
}


kp_user_sj() {
  if [[ -z "$1" ]]; then
    echo "Usage: kp_user_sj 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get UserName "$1"
}
