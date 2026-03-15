alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v'
alias gca='git commit -a -v'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'
alias grt='cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"'
alias gs='git status -sb'
alias gst='git status'

grename() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: grename old_branch new_branch"
    return 1
  fi

  git branch -m "$1" "$2" &&
    git push origin :"$1" &&
    git push --set-upstream origin "$2"
}
