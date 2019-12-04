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
      ;;
  'FreeBSD')
      ;;
  'WindowsNT')
      ;;
  'Darwin')
      ( $DIRECTORY/osx.sh ) ;;
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

# Do common setup stuff here, if any...


# Flag that we have done initial setup
touch $DIRECTORY/.setup
