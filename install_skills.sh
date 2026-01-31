#!/bin/bash

# Install Agent Skills
# This script installs custom skills for AI coding agents using the Vercel skills CLI

set -e

# Default agents to install for
AGENTS=("codex" "claude-code" "pi" "opencode")
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
    # Add more skills here as needed
    # "https://github.com/owner/repo/tree/main/skills/skill-name"
)

for skill in "${EXTERNAL_SKILLS[@]}"; do
    echo "   Installing from: $skill"
    npx skills add "$skill" $AGENT_FLAGS $SCOPE_FLAG -y
done

echo ""
echo "✅ Skills installed successfully!"
echo ""
echo "📍 Installation locations:"
if [ "$SCOPE" = "global" ]; then
    echo "   ~/.pi/agent/skills/ (for claude-code, pi)"
    echo "   ~/.codex/skills/ (for codex)"
    echo "   ~/.opencode/skills/ (for opencode)"
else
    echo "   ./.pi/agent/skills/ (for claude-code, pi)"
    echo "   ./.codex/skills/ (for codex)"
    echo "   ./.opencode/skills/ (for opencode)"
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
