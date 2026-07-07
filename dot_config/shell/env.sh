# Shared interactive shell environment.

path_prepend() {
  [ -n "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  [ -n "$1" ] || return 0
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

export GOPATH="${GOPATH:-$HOME/go}"
export BULKERCFG="${BULKERCFG:-$HOME/.config/bulker.conf}"

if [ -d "$HOME/.local/share/jdks/jdk-21.0.11+10" ]; then
  export JAVA_HOME="$HOME/.local/share/jdks/jdk-21.0.11+10"
fi

[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

path_append "$HOME/.local/share/flatpak/exports/bin"
path_append "/var/lib/flatpak/exports/bin"
path_append "/usr/local/go/bin"
path_append "$GOPATH/bin"
path_append "$HOME/.local/bin"
path_append "$HOME/bin"
path_append "$HOME/.local/share/chezmoi/scripts"

if [ -d "$HOME/.juliaup/bin" ]; then
  path_prepend "$HOME/.juliaup/bin"
fi

if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
  path_prepend "$ANDROID_HOME/emulator"
  path_prepend "$ANDROID_HOME/platform-tools"
  path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
fi

[ -n "${JAVA_HOME:-}" ] && path_prepend "$JAVA_HOME/bin"

export PATH
