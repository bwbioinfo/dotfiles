#!/usr/bin/env bash
set -euo pipefail

if ! command -v nmcli >/dev/null 2>&1; then
  echo "nmcli not found. Install NetworkManager tools to use this shortcut." >&2
  exit 1
fi

ETH_DEVICE="${1:-}"

if [[ -z "$ETH_DEVICE" ]]; then
  ETH_DEVICE="$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "ethernet" {print $1; exit}')"
fi

if [[ -z "$ETH_DEVICE" ]]; then
  echo "No ethernet device found." >&2
  exit 1
fi

STATE="$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: -v dev="$ETH_DEVICE" '$1 == dev && $2 == "ethernet" {print $3; exit}')"

if [[ -z "$STATE" ]]; then
  echo "Unable to determine state for ethernet device: $ETH_DEVICE" >&2
  exit 1
fi

case "$STATE" in
  connected|connecting)
    nmcli device disconnect "$ETH_DEVICE"
    MESSAGE="disabled"
    ;;
  *)
    nmcli device connect "$ETH_DEVICE"
    MESSAGE="enabled"
    ;;
esac

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Wired network" "Wired network ${MESSAGE} on ${ETH_DEVICE}" >/dev/null 2>&1 || true
fi
