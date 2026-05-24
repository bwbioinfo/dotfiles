#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found. This script is for Ubuntu/Debian apt based systems." >&2
  exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
else
  SUDO=(sudo)
fi

APT_PACKAGES=(
  bash
  ca-certificates
  curl
  flatpak
  gawk
  git
  grim
  libnotify-bin
  network-manager
  openssh-client
  ripgrep
  slurp
  swappy
  wget
  zsh
)

OPTIONAL_APT_PACKAGES=(
  chezmoi
  fd-find
  nushell
  starship
  zoxide
)

FLATPAK_PACKAGES=(
  org.flameshot.Flameshot
)

available_packages=()
missing_optional=()

echo "Updating apt package metadata..."
"${SUDO[@]}" apt-get update

for package in "${APT_PACKAGES[@]}"; do
  if apt-cache show "$package" >/dev/null 2>&1; then
    available_packages+=("$package")
  else
    echo "Required apt package not found in configured repositories: $package" >&2
    exit 1
  fi
done

for package in "${OPTIONAL_APT_PACKAGES[@]}"; do
  if apt-cache show "$package" >/dev/null 2>&1; then
    available_packages+=("$package")
  else
    missing_optional+=("$package")
  fi
done

echo "Installing apt packages..."
"${SUDO[@]}" apt-get install -y "${available_packages[@]}"

if command -v flatpak >/dev/null 2>&1; then
  if ! flatpak remote-list --columns=name | grep -qx flathub; then
    echo "Adding Flathub remote..."
    "${SUDO[@]}" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi

  for package in "${FLATPAK_PACKAGES[@]}"; do
    echo "Installing Flatpak package: $package"
    flatpak install -y flathub "$package"
  done
fi

if ((${#missing_optional[@]})); then
  echo
  echo "These optional tools were not available from configured apt repositories:"
  printf '  %s\n' "${missing_optional[@]}"
  echo "Install them from upstream or enable the needed repository if you want those integrations."
fi

if ! command -v beads >/dev/null 2>&1; then
  echo "Installing beads..."
  curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash
else
  echo "beads already installed, skipping."
fi
