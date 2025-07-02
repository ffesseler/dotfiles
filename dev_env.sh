#!/bin/sh

asdf plugin add nodejs
asdf install nodejs 20.11.1
asdf set -u nodejs 20.11.1

npm install -g @anthropic-ai/claude-code

uv python install 3.11
