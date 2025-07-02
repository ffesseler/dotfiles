#!/bin/bash

# ~/.osx

# Ask for the administrator password upfront
sudo -v

# Dock
defaults write com.apple.dock wvous-tl-corner -int 13
killall Dock
