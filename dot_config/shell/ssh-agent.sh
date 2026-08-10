# Reuse a single ssh-agent across interactive shells.

if command -v ssh-agent >/dev/null 2>&1; then
  agent_env="$HOME/.ssh/agent.env"
  agent_is_reachable=false

  if [ -r "$agent_env" ]; then
    . "$agent_env" >/dev/null 2>&1
  fi

  # A stale Unix socket can remain after its agent exits. ssh-add distinguishes
  # that case (exit 2) from a reachable, empty agent (exit 1).
  if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
    if ssh-add -l >/dev/null 2>&1; then
      agent_is_reachable=true
    else
      agent_status=$?
      if [ "$agent_status" -eq 1 ]; then
        agent_is_reachable=true
      fi
    fi
  fi

  if [ "$agent_is_reachable" != true ]; then
    mkdir -p "$HOME/.ssh"
    tmp_agent_env="$(mktemp "$HOME/.ssh/.agent.env.XXXXXX")"
    if ssh-agent -s > "$tmp_agent_env"; then
      . "$tmp_agent_env" >/dev/null 2>&1
      mv "$tmp_agent_env" "$agent_env"
    else
      rm -f "$tmp_agent_env"
      unset agent_env agent_is_reachable agent_status tmp_agent_env
      return 1
    fi
  fi

  export SSH_AUTH_SOCK SSH_AGENT_PID
  unset agent_env agent_is_reachable agent_status tmp_agent_env
fi
