#!/usr/bin/env bash

DIRECTORY=$(cd `dirname $0` && pwd)

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
RTN=$?
if [[ $RTN != 0 ]]; then
    echo "exiting"
    exit $RTN
fi

# Tap Homebrew repos
cat $DIRECTORY/brew.taps | xargs -L 1 brew tap

# Install homebrew apps
cat $DIRECTORY/brew.packages | xargs brew install
cat $DIRECTORY/brew.cask.packages | xargs brew cask install
