# This is ZSH specific config.  This file is loaded first by ZSH.

# Load our generic stuff first.  It can be overwritten later.
# Only load if we haven't loaded yet.
if [[ ! $PROFILE ]]; then
    ## https://superuser.com/questions/187639/zsh-not-hitting-profile
    emulate sh
    . ~/.profile
    emulate zsh
fi

# We are loading ZPROFILE - set a var
export ZPROFILE=true
