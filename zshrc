export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# --- Git Aliases ---
alias ga='git add -p'
alias gst='git status'
alias gco='git checkout'
alias gc='git commit'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gbr='git branch'
alias gp='git push'
alias gpl='git pull'
alias gcob='git checkout -b'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glast='git log -1 HEAD'

# --- LLM ---

lite() {
  llm -m gemini-2.5-flash-lite-preview-06-17 "$@" | glow -
}

flash() {
  llm -m gemini-2.5-flash "$@" | glow -
}

hn() {
  local number="$1"
  llm -m gemini-2.5-flash -f "hn:$number" 'summary with illustrative direct quotes' -o thinking_budget 0 > /tmp/llm_output.md && glow -w 200 /tmp/llm_output.md && glow -w 200 -p /tmp/llm_output.md
}


# --- Replace ---
alias cat='bat'


