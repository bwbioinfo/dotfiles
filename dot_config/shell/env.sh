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

[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

path_append "/usr/local/go/bin"
path_append "$GOPATH/bin"
path_append "$HOME/bin"

if [ -d "$HOME/.juliaup/bin" ]; then
  path_prepend "$HOME/.juliaup/bin"
fi

if [ -d "$HOME/Android/Sdk" ]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
  path_append "$ANDROID_HOME/platform-tools"
  path_append "$ANDROID_HOME/emulator"
  path_append "$ANDROID_HOME/cmdline-tools/latest/bin"
fi

export PATH
