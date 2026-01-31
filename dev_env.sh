#!/bin/sh

asdf plugin add nodejs
asdf install nodejs 22.17.0
asdf set -u nodejs 22.17.0

npm install -g cchistory
npm install -g eas-cli
npm install -g @mariozechner/pi-coding-agent
npm install -g pnpm

uv python install 3.11

llm install llm-gemini
llm keys set gemini
llm install llm-hacker-news