#!/usr/bin/env bash

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Tap Homebrew repos
cat brew.taps | xargs -L 1 brew tap

# Install homebrew apps
cat brew.packages | xargs brew install
cat brew.cask.packages | xargs brew cask install
