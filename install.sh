#!/usr/bin/env bash

# Adapted from:
# https://dev.to/writingcode/how-i-manage-my-dotfiles-using-gnu-stow-4l59

# Check if we are in an SSH session and set a variable if so
# Stolen from: https://unix.stackexchange.com/questions/9605/how-can-i-detect-if-the-shell-is-controlled-from-ssh
# This function is duplicated in .profile.  We should store it in a single common location and source it in.
# This variable *MUST* be set before we call __setup/setup.sh
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE=remote/ssh
# many other tests omitted
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) SESSION_TYPE=remote/ssh;;
    tmux) SESSION_TYPE=tmux;;
  esac
fi
export SESSION_TYPE=$SESSION_TYPE

# Check and run initial setup
( __setup/setup.sh )
RTN=$?
if [[ $RTN != 0 ]]; then
    exit $RTN
fi

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
#    stow -v -R -t ${usr} -d $DIRECTORY/${base} --dotfiles --ignore "\.DS_Store|\.gitkeep|README.*" ${app}
    stow -v -R -t ${usr} -d $DIRECTORY/${base} --ignore "\.DS_Store|\.gitkeep|README.*" ${app}
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
