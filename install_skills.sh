#!/bin/bash

# Install Agent Skills
# This script installs custom skills for AI coding agents using the Vercel skills CLI

set -e

# Default agents to install for
# Antigravity CLI is exposed by the skills CLI as "antigravity-cli" (not "agy").
AGENTS=("codex" "claude-code" "pi" "opencode" "antigravity" "antigravity-cli")
SCOPE="${1:-global}"

echo "🎯 Installing Agent Skills"
echo "   Agents: ${AGENTS[*]}"
echo "   Scope: $SCOPE"
echo ""

# Determine scope flag
SCOPE_FLAG=""
if [ "$SCOPE" = "global" ]; then
    SCOPE_FLAG="--global"
fi

# Check if npx is available
if ! command -v npx &> /dev/null; then
    echo "❌ Error: npx is not installed. Please install Node.js first."
    exit 1
fi

# Build agent flags
AGENT_FLAGS=""
for agent in "${AGENTS[@]}"; do
    AGENT_FLAGS="$AGENT_FLAGS -a $agent"
done

# Work around skills CLI 1.5.x installing Antigravity global skills into
# ~/.agents/skills even though Antigravity CLI reads ~/.gemini/antigravity-cli/skills.
# Project installs are already correct: ./.agents/skills/.
sync_antigravity_global_skills() {
    if [ "$SCOPE" != "global" ]; then
        return
    fi

    local source_dir="$HOME/.agents/skills"
    local targets=(
        "$HOME/.gemini/antigravity/skills"
        "$HOME/.gemini/antigravity-cli/skills"
    )

    if [ ! -d "$source_dir" ] || [ -z "$(ls -A "$source_dir" 2>/dev/null)" ]; then
        echo "⚠️  No Antigravity source skills found in $source_dir; skipping Antigravity sync."
        return
    fi

    echo "🔁 Syncing skills to Antigravity global directories..."
    for target in "${targets[@]}"; do
        mkdir -p "$target"
        # Dereference symlinks created by `npx skills add` so Antigravity sees real files.
        rsync -aL "$source_dir/" "$target/"
        echo "   Synced: $target"
    done
    echo ""
}

# Install skills from local dotfiles/skills directory (if it exists and has skills)
if [ -d "skills" ] && [ "$(ls -A skills 2>/dev/null)" ]; then
    echo "📦 Installing skills from dotfiles/skills directory..."
    npx skills add ./skills --skill '*' $AGENT_FLAGS $SCOPE_FLAG -y
    echo ""
fi

# Install specific skills from external repositories
echo "📦 Installing skills from external repositories..."

# List of external skills to install (GitHub paths)
EXTERNAL_SKILLS=(
    "https://github.com/anthropics/skills/tree/main/skills/skill-creator"
    "https://github.com/nicobailon/surf-cli/tree/main/skills/surf"
    "https://github.com/elithrar/dotfiles/tree/main/.agents/skills/web-perf"
    "https://github.com/danpeg/bug-hunt"
    "https://github.com/openclaw/agent-skills/tree/main/skills/autoreview"
)

for skill in "${EXTERNAL_SKILLS[@]}"; do
    echo "   Installing from: $skill"
    npx skills add "$skill" $AGENT_FLAGS $SCOPE_FLAG -y
done

echo ""
sync_antigravity_global_skills

echo "✅ Skills installed successfully!"
echo ""
echo "📍 Installation locations:"
if [ "$SCOPE" = "global" ]; then
    echo "   ~/.pi/agent/skills/ (for claude-code, pi)"
    echo "   ~/.codex/skills/ (for codex)"
    echo "   ~/.opencode/skills/ (for opencode)"
    echo "   ~/.gemini/antigravity/skills/ (for antigravity)"
    echo "   ~/.gemini/antigravity-cli/skills/ (for agy / antigravity-cli)"
else
    echo "   ./.pi/agent/skills/ (for claude-code, pi)"
    echo "   ./.codex/skills/ (for codex)"
    echo "   ./.opencode/skills/ (for opencode)"
    echo "   ./.agents/skills/ (for antigravity, agy / antigravity-cli)"
fi

echo ""
echo "💡 Manage your skills:"
echo "   - List installed: npx skills list"
echo "   - Update skills:  npx skills update"
echo "   - Remove skills:  npx skills remove <skill-name>"
echo ""
echo "🔧 To install with different scope:"
echo "   $0 global   # Install globally (default)"
echo "   $0 project  # Install to current project"
echo ""
