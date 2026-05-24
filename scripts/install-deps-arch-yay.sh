#!/usr/bin/env bash
set -euo pipefail

if ! command -v yay >/dev/null 2>&1; then
  echo "yay not found. Install yay first, then rerun this script." >&2
  exit 1
fi

PACKAGES=(
  bash
  ca-certificates
  chezmoi
  curl
  fd
  flatpak
  gawk
  git
  grim
  libnotify
  networkmanager
  nushell
  openssh
  ripgrep
  slurp
  starship
  swappy
  wget
  zoxide
  zsh
)

FLATPAK_PACKAGES=(
  org.flameshot.Flameshot
)

echo "Installing Arch packages with yay..."
yay -S --needed "${PACKAGES[@]}"

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak remote-list --columns=name | grep -qx flathub; then
    echo "Adding Flathub remote..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi

  for package in "${FLATPAK_PACKAGES[@]}"; do
    echo "Installing Flatpak package: $package"
    flatpak install -y flathub "$package"
  done
fi

if ! command -v beads >/dev/null 2>&1; then
  echo "Installing beads..."
  curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash
else
  echo "beads already installed, skipping."
fi
