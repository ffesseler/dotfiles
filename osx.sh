#!/bin/bash

# ~/.osx

# Ask for the administrator password upfront
sudo -v

# Disable the current Spotlight shortcut (usually Cmd+Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

# Set Option+Space for Spotlight
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>524288</integer></array><key>type</key><string>standard</string></dict></dict>"

# Dock
defaults write com.apple.dock wvous-tl-corner -int 13
killall Dock
