#!/bin/sh

asdf plugin add nodejs
asdf install nodejs 22.17.0
asdf set -u nodejs 22.17.0

npm install -g cchistory
npm install -g eas-cli
npm install -g @mariozechner/pi-coding-agent
npm install -g pnpm
npm install -g surf-cli

uv python install 3.11

llm install llm-gemini
llm keys set gemini
llm install llm-hacker-news

curl -fsSL https://plannotator.ai/install.sh | bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/lightonai/next-plaid/releases/latest/download/colgrep-installer.sh | sh
