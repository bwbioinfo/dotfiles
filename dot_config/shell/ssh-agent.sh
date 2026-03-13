# Reuse a single ssh-agent across interactive shells.

if command -v ssh-agent >/dev/null 2>&1; then
  agent_env="$HOME/.ssh/agent.env"

  if [ -r "$agent_env" ]; then
    . "$agent_env" >/dev/null 2>&1
  fi

  if [ -z "${SSH_AUTH_SOCK:-}" ] || [ ! -S "${SSH_AUTH_SOCK}" ]; then
    mkdir -p "$HOME/.ssh"
    ssh-agent -s > "$agent_env"
    . "$agent_env" >/dev/null 2>&1
  fi

  export SSH_AUTH_SOCK SSH_AGENT_PID
  unset agent_env
fi
