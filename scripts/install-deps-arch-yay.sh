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
  r
  ripgrep
  slurp
  starship
  swappy
  unzip
  wget
  zoxide
  zsh
)

FLATPAK_PACKAGES=(
  org.flameshot.Flameshot
)

install_java_21() {
  local java_home="$HOME/.local/share/jdks/jdk-21.0.11+10"
  local tmp

  if [ -x "$java_home/bin/java" ]; then
    echo "Java 21 already installed at $java_home, skipping."
    return 0
  fi

  echo "Installing Java 21 to $java_home..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  mkdir -p "$java_home"
  curl -fL \
    'https://api.adoptium.net/v3/binary/version/jdk-21.0.11%2B10/linux/x64/jdk/hotspot/normal/eclipse?project=jdk' \
    -o "$tmp/jdk.tar.gz"
  tar -xzf "$tmp/jdk.tar.gz" --strip-components=1 -C "$java_home"
  rm -rf "$tmp"
  trap - RETURN
}

install_android_sdk() {
  local android_home="$HOME/Android/Sdk"
  local java_home="$HOME/.local/share/jdks/jdk-21.0.11+10"
  local ndk_version="29.0.14206865"
  local sdkmanager="$android_home/cmdline-tools/latest/bin/sdkmanager"
  local cmdline_tools_url
  local tmp

  if [ ! -x "$java_home/bin/java" ]; then
    echo "Java 21 is required before installing the Android SDK." >&2
    return 1
  fi

  if [ ! -x "$sdkmanager" ]; then
    echo "Installing Android command-line tools to $android_home..."
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN

    cmdline_tools_url="$(
      curl -fsSL https://dl.google.com/android/repository/repository2-1.xml |
        awk '
          /<remotePackage path="cmdline-tools;latest"/ { in_package = 1 }
          in_package && /<url>commandlinetools-linux-/ {
            sub(/.*<url>/, "")
            sub(/<\/url>.*/, "")
            print "https://dl.google.com/android/repository/" $0
            exit
          }
        '
    )"

    if [ -z "$cmdline_tools_url" ]; then
      echo "Unable to find latest Android command-line tools URL." >&2
      return 1
    fi

    mkdir -p "$android_home/cmdline-tools/latest"
    curl -fL "$cmdline_tools_url" -o "$tmp/commandlinetools.zip"
    unzip -q "$tmp/commandlinetools.zip" -d "$tmp"
    mv "$tmp/cmdline-tools"/* "$android_home/cmdline-tools/latest/"
    rm -rf "$tmp"
    trap - RETURN
  fi

  echo "Installing Android SDK packages..."
  export JAVA_HOME="$java_home"
  export ANDROID_HOME="$android_home"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
  yes | "$sdkmanager" --sdk_root="$ANDROID_HOME" --licenses >/dev/null || true
  "$sdkmanager" --sdk_root="$ANDROID_HOME" --install \
    "build-tools;35.0.1" \
    "cmdline-tools;latest" \
    "emulator" \
    "ndk;$ndk_version" \
    "platform-tools" \
    "platforms;android-35" \
    "system-images;android-35;google_apis;x86_64"
}

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

install_java_21
install_android_sdk

if ! command -v rustup >/dev/null 2>&1; then
  echo "Installing Rust with rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "rustup already installed, skipping."
fi

if ! command -v beads >/dev/null 2>&1; then
  echo "Installing beads..."
  curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash
else
  echo "beads already installed, skipping."
fi
