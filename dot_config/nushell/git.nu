alias g = git
alias ga = git add
alias gaa = git add --all
alias gb = git branch
alias gc = git commit -v
alias gca = git commit -a -v
alias gco = git checkout
alias gd = git diff
alias gds = git diff --staged
alias gl = git pull
alias gp = git push
alias gs = git status -sb
alias gst = git status

def --env grt [] {
    let result = (^git rev-parse --show-toplevel | complete)
    if $result.exit_code == 0 {
        cd ($result.stdout | str trim)
    }
}

def grename [old_branch: string, new_branch: string] {
    ^git branch -m $old_branch $new_branch
    if $env.LAST_EXIT_CODE != 0 {
        return
    }

    ^git push origin $":($old_branch)"
    if $env.LAST_EXIT_CODE != 0 {
        return
    }

    ^git push --set-upstream origin $new_branch
}
