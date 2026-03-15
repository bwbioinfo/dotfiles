#!/usr/bin/env bash
set -euo pipefail

for cmd in grim slurp swappy; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found." >&2
    exit 1
  fi
done

geometry="$(slurp -f '%x,%y %wx%h')" || exit 1

if [[ -z "$geometry" ]]; then
  echo "No selection made." >&2
  exit 1
fi

grim -t ppm -g "$geometry" - | swappy -f -
