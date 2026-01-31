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
alias gcl='git commit -c HEAD'

# --- LLM ---

lite() {
  llm -m gemini/gemini-flash-lite-latest "$@" | glow -w 200 -
}

# CLI command generator configuration
CLI_MODEL="gemini/gemini-2.5-flash-lite"
CLI_PROMPT="Output the bash-compatible command line only that works on macOS. No markdown, no code blocks, no explanations. Just the raw command. I should be able to copy paste the result and it should work directly in bash on macOS"
CLI_SHORTCUT='^X'  # Ctrl+X

cli() {
  local result=$(llm -m "$CLI_MODEL" "$@ .$CLI_PROMPT" | \
  sed 's/^```bash//; s/^```//; s/```$//' | \
  tr -s '[:space:]' ' ' | \
  sed 's/^ //; s/ $//')
  echo "$result" | pbcopy
  print -z "$result"
}

# ZLE widget for cli - press keyboard shortcut to convert prompt to command
_cli_widget() {
  local prompt="$BUFFER"
  if [[ -z "$prompt" ]]; then
    return
  fi

  # Show processing message
  BUFFER="⏳ Generating command..."
  zle redisplay

  # Generate command
  local result=$(llm -m "$CLI_MODEL" "$prompt. $CLI_PROMPT" | \
  sed 's/^```bash//; s/^```//; s/```$//' | \
  tr -s '[:space:]' ' ' | \
  sed 's/^ //; s/ $//')

  # Replace buffer with result
  if [[ -n "$result" ]]; then
    BUFFER="$result"
    echo "$result" | pbcopy
  else
    BUFFER=""
  fi

  zle end-of-line
}
zle -N _cli_widget
bindkey "$CLI_SHORTCUT" _cli_widget

syntax() {
  llm -m gemini/gemini-flash-lite-latest "$@. Output only the syntax and an
example" | glow -w 200 -
}

flash() {
  llm -m gemini/gemini-3-flash-preview "$@" | glow -w 200 -
}

hn() {
  local number="$1"
  llm -m gemini/gemini-2.5-flash -f "hn:$number" 'summary with illustrative direct quotes' -o thinking_budget 0 > /tmp/llm_output.md && glow -w 200 /tmp/llm_output.md && glow -w 200 -p /tmp/llm_output.md
}

thread_insights() {
  local url="$1"
  bird thread "$url" | llm -m gemini/gemini-3-flash-preview "What are the key insights and main takeaways from this thread?"
}

# --- Replace ---
alias cat='bat'
alias rm='trash'


# Added by LM Studio CLI (lms)
export PATH="$PATH:~/.lmstudio/bin"
# End of LM Studio CLI section

# --- Android SDK ---
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

