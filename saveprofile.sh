#!/usr/bin/env bash

# Saves various configurations on the current system for use with this
# dotfiles repo


# Configuration

## Subdirectory to store brew configuration in
BREWDIR='__setup';


# Program

BASEDIR="`dirname \"$0\"`";


## Store the Homebrew configuration

BREWDIR="$BASEDIR/$BREWDIR";

if [[ -d $BREWDIR ]]; then
	RTN=0;
	brew leaves > "$BREWDIR/brew.packages";
	let RTN=$RTN+$?;
	brew tap > "$BREWDIR/brew.taps";
	let RTN=$RTN+$?;
	brew cask list > "$BREWDIR/brew.cask.packages";
	let RTN=$RTN+$?;
	
	if [[ $RTN > 0 ]]; then
		echo "Errors while saving Homebrew configuration";
		exit 1;
	fi
fi
