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
path add "/usr/local/go/bin"

if not ("GOPATH" in $env) {
    $env.GOPATH = $"($nu.home-dir)/go"
}

path add $"($env.GOPATH)/bin"

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

# Reuse a single ssh-agent across Nushell, Bash, and Zsh sessions. The state
# file contains only the agent socket and PID, never a key or passphrase.
if ((which ssh-agent | length) > 0) {
    let agent_env = $"($nu.home-dir)/.ssh/agent.env"

    let agent_is_reachable = {
        if not ("SSH_AUTH_SOCK" in $env) {
            false
        } else if not ($env.SSH_AUTH_SOCK | path exists) {
            false
        } else {
            let result = (do -i { ^ssh-add -l | complete })
            $result.exit_code in [0 1]
        }
    }

    if (not (do $agent_is_reachable)) and ($agent_env | path exists) {
        let agent_state = (open --raw $agent_env | parse -r '(?m)^SSH_AUTH_SOCK=(?<socket>[^;]+);.*\r?\nSSH_AGENT_PID=(?<pid>[^;]+);')
        if (($agent_state | length) > 0) {
            $env.SSH_AUTH_SOCK = $agent_state.0.socket
            $env.SSH_AGENT_PID = $agent_state.0.pid
        }
    }

    if not (do $agent_is_reachable) {
        mkdir ($agent_env | path dirname)
        let result = (^ssh-agent -s | complete)
        if $result.exit_code != 0 {
            error make {msg: "Unable to start ssh-agent"}
        }
        let agent_state = ($result.stdout | parse -r '(?m)^SSH_AUTH_SOCK=(?<socket>[^;]+);.*\r?\nSSH_AGENT_PID=(?<pid>[^;]+);')
        if (($agent_state | length) == 0) {
            error make {msg: "ssh-agent did not return its environment"}
        }
        $env.SSH_AUTH_SOCK = $agent_state.0.socket
        $env.SSH_AGENT_PID = $agent_state.0.pid
        $result.stdout | save -f $agent_env
        ^chmod 600 $agent_env
    }
}
