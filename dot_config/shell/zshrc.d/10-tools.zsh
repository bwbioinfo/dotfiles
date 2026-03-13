command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

if [[ -f "$HOME/.config/gastown/shell-hook.sh" ]]; then
  source "$HOME/.config/gastown/shell-hook.sh"
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
