# env.nu
#
# Installed by:
# version = "0.107.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.
use std/util "path add"

path add $"($nu.home-dir)/.local/bin"
path add $"($nu.home-dir)/.local/share/chezmoi/scripts"
path add $"($nu.home-dir)/.cargo/bin"
path add $"($nu.home-dir)/.local/share/flatpak/exports/bin"
path add "/var/lib/flatpak/exports/bin"

let java_home = $"($nu.home-dir)/.local/share/jdks/jdk-21.0.11+10"
if ($java_home | path exists) {
    $env.JAVA_HOME = $java_home
}

let android_home = $"($nu.home-dir)/Android/Sdk"
if ($android_home | path exists) {
    $env.ANDROID_HOME = $android_home
    $env.ANDROID_SDK_ROOT = $android_home
    $env.ANDROID_NDK_HOME = $"($android_home)/ndk/29.0.14206865"
    path add $"($android_home)/emulator"
    path add $"($android_home)/platform-tools"
    path add $"($android_home)/cmdline-tools/latest/bin"
}

if ($java_home | path exists) {
    path add $'($java_home)/bin'
}
