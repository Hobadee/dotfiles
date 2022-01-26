#!/usr/bin/env bash


APTPKGS="emacs-nox stow zsh"
YUMPKGS="emacs-nox zsh sqlite3"


DIRECTORY=$(cd `dirname $0` && pwd)

# Check if we are APT or YUM based
if [[ -x $(which apt) ]]; then
    # We are APT based
    echo "Using APT";
elif [[ -x $(which yum) ]]; then
    # We are YUM based
    echo "Using YUM";
else
    # No APT or YUM.
    echo "No known package manager!";
fi
