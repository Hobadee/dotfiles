#!/usr/bin/env bash

DIRECTORY=$(cd `dirname $0` && pwd)

# Install Homebrew
echo "Installing Homebrew";
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "exiting"
    exit $RTN
fi

# Tap Homebrew repos
cat $DIRECTORY/brew.taps | xargs -L 1 brew tap                  # Pull list with `brew tap`

# Install homebrew apps
cat $DIRECTORY/brew.packages | xargs brew install               # Pull list with `brew leaves`
cat $DIRECTORY/brew.cask.packages | xargs brew cask install     # Pull list with `brew cask list`
