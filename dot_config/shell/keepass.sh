# Shared KeePass helpers.

_kp_sj_get() {
  local attribute="$1"
  local db="$2"
  local entry="$3"

  if [[ -z "$db" || -z "$entry" ]]; then
    echo "Usage: _kp_sj_get <attribute> <database.kdbx> 'Group/Entry name'" >&2
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
  local db="$1"
  local entry="$2"

  if [[ -z "$db" || -z "$entry" ]]; then
    echo "Usage: kp_token_sj <database.kdbx> 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get Password "$db" "$entry"
}


kp_url_sj() {
  local db="$1"
  local entry="$2"

  if [[ -z "$db" || -z "$entry" ]]; then
    echo "Usage: kp_url_sj <database.kdbx> 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get URL "$db" "$entry"
}


kp_user_sj() {
  local db="$1"
  local entry="$2"

  if [[ -z "$db" || -z "$entry" ]]; then
    echo "Usage: kp_user_sj <database.kdbx> 'Group/Entry name'" >&2
    return 1
  fi

  _kp_sj_get UserName "$db" "$entry"
}
