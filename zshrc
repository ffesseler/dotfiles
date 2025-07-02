export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# --- Git Aliases ---
alias gst='git status'
alias gco='git checkout'
alias gci='git commit'
alias gcm='git commit -m'
alias gbr='git branch'
alias gps='git push'
alias gpl='git pull'
alias gcob='git checkout -b'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glast='git log -1 HEAD'
