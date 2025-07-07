#!/bin/sh

asdf plugin add nodejs
asdf install nodejs 22.17.0
asdf set -u nodejs 22.17.0

npm install -g @anthropic-ai/claude-code

uv python install 3.11

llm install llm-gemini
llm keys set gemini
