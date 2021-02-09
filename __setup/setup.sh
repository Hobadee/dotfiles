#!/usr/bin/env bash

DIRECTORY=$(cd `dirname $0` && pwd)

if [[ -f "$DIRECTORY/.setup" ]]; then
    exit 0
fi

echo "Initial setup hasn't been run yet; running."

# OS-specific initial setup stuff
OS="`uname`"
case $OS in
  'Linux')
      ( $DIRECTORY/os.linux.sh ) ;;
  'FreeBSD')
      ;;
  'WindowsNT')
      ;;
  'Darwin')
      ( $DIRECTORY/os.osx.sh ) ;;
  'SunOS')
      ;;
  'AIX')
      ;;
  *) ;;
esac

RTN=$?
if [[ $RTN != 0 ]]; then
    exit $RTN
fi


# Remove pre-existing home dir configs:
rm ~/.bash_profile ~/.zshrc

# Make some common directories...
mkdir ~/tmp ~/log ~/src ~/lib


# Install Nerdfonts
# We don't need to install if we are in an SSH session.
if [[ $SESSION_TYPE != "remote/ssh" ]]; then
    pushd ~/src
    REPO=nerd-fonts
    git clone https://github.com/ryanoasis/$REPO.git --depth 1
    pushd ./$REPO
    ./install.sh
    popd
    rm -rf ./$REPO
    popd
fi


# Flag that we have done initial setup
touch $DIRECTORY/.setup
