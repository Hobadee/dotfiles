#!/usr/bin/env bash

# Adapted from:
# https://dev.to/writingcode/how-i-manage-my-dotfiles-using-gnu-stow-4l59

# make sure we have pulled in and updated any submodules
git submodule init
git submodule update

# what directories should be installable by all users including the root user
base=(
    profile
    home
)

# folders that should, or only need to be installed for a local user
useronly=(
    bin
    git
    fortunes
)

# run the stow command for the passed in directory ($2) in location $1
stowit() {
    usr=$1
    base=$2
    app=$3
    # -v
    #    verbose
    # -R
    #    recursive
    # -t
    #    target
    # -d
    #    Set the stow directory instead of current directory
    # --dotfiles
    #    Change any files prepended with "dot-" to actual dotfiles, removing the "dot-" prefix
    DIRECTORY=$(cd `dirname $0` && pwd)
    stow -v -R -t ${usr} -d $DIRECTORY/${base} --dotfiles --ignore "\.DS_Store|\.gitkeep|README.*" ${app}
}

commonOS="Common"
OS="`uname`"
case $OS in
  'Linux')
    OS='Linux' ;;
  'FreeBSD')
    OS='FreeBSD' ;;
  'WindowsNT')
    OS='Windows' ;;
  'Darwin')
    OS='OSX' ;;
  'SunOS')
    OS='Solaris' ;;
  'AIX')
    OS='AIX' ;;
  *) ;;
esac


echo ""
echo "Stowing apps for user: ${whoami}"

# install apps available to local users and root
for app in ${base[@]}; do
    if [[ -e "$OS/$app" ]]; then
	stowit "${HOME}" $OS $app
    fi
    if [[ -e "$commonOS/$app" ]]; then
	stowit "${HOME}" $commonOS $app
    fi
done

# install only user space folders
if ! [[ "$(whoami)" = *"root"* ]]; then
    for app in ${useronly[@]}; do
	if [[ -e "$OS/$app" ]]; then
            stowit "${HOME}" $OS $app
	fi
	if [[ -e "$commonOS/$app" ]]; then
	    stowit "${HOME}" $commonOS $app
	fi
    done
fi

echo ""
echo "##### ALL DONE"
