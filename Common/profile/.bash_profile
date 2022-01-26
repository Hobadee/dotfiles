#  ---------------------------------------------------------------------------
#
#  Description:  This file holds all my BASH configurations and aliases
#
#  Note: A bunch of stuff has been moved to my .profile so I can share it with ZSH
#  This file should keep the BASH specific customization.
#
#  ---------------------------------------------------------------------------
#  Sources I have stolen from:
#  http://natelandau.com/my-mac-osx-bash_profile/   (Stolen heavily from here)
#  http://hints.macworld.com/comment.php?mode=view&cid=24491
#  http://kirsle.net/wizards/ps1.html
#  Wicked Cool Shell Scripts
#  ---------------------------------------------------------------------------


# Load our generic stuff first.  It can be overwritten later.
if [[ ! $PROFILE ]]; then
source ~/.profile
fi

export BASH_PROFILE=true


#   -------------------------------
#   ENVIRONMENT CONFIGURATION
#   -------------------------------

#   Change Prompt
#   ------------------------------------------------------------
#   OSX Default
#   export PS1="\h:\W \u\$"
#
#   Custom bash prompt via kirsle.net/wizards/ps1.html
	export PS1="[\[$(tput setaf 1)\]\[$(tput bold)\]\u\[$(tput setaf 2)\]@\h\[$(tput setaf 4)\] \w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"
	export PS2=">"
#	export PS3=""
#	export PS4="+"


#   -----------------------------
#   MAKE TERMINAL BETTER
#   -----------------------------
if [[ -x titleterm ]]; then
	#   Change Terminal Title
	#   ------------------------------------------------------------
	#   Stolen from Wicked Cool Shell Scripts p.310
	#   Update OSX Terminal title bar with current working dir
	#
	#   OSX Default/Builtin
	#   export PROMPT_COMMAND="update_terminal_cwd;"
	export PROMPT_COMMAND="titleterm \"\$PWD\""
fi

#   Add color to terminal
#   ------------------------------------------------------------
#   Stolen from:
#   http://natelandau.com/my-mac-osx-bash_profile/
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Enable BASH completion	
if [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
    . /usr/local/share/bash-completion/bash_completion
elif [[ -f /sw/etc/bash_completion ]]; then  # OSX may not load the above.  This is suggested as well.
    . /sw/etc/bash_completion
elif [[ -x $(command -v brew) ]]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then  # Older reference
        . $(brew --prefix)/etc/bash_completion
    fi
fi


# The following aliases/commands are only useful on OSX
if [[ $OS_OSX ]]; then
    alias which='type -all'								# which:	Find executables

    #   cdf:  'Cd's to frontmost window of MacOS Finder
    #   ------------------------------------------------------
        cdf () {
            currFolderPath=$( /usr/bin/osascript <<EOT
                tell application "Finder"
                    try
                set currFolder to (folder of the front window as alias)
                    on error
                set currFolder to (path to desktop folder as alias)
                    end try
                    POSIX path of currFolder
                end tell
EOT
            )
            echo "cd to \"$currFolderPath\""
            cd "$currFolderPath"
        }

    #   pwdf:  Prints the 'cd' of the frontmost window of MacOS Finder
    #   ------------------------------------------------------
        pwdf () {
            currFolderPath=$( /usr/bin/osascript <<EOT
                tell application "Finder"
                    try
                set currFolder to (folder of the front window as alias)
                    on error
                set currFolder to (path to desktop folder as alias)
                    end try
                    POSIX path of currFolder
                end tell
EOT
            )
            echo "$currFolderPath"
        }
fi


#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
extract () {
	if [ -f $1 ] ; then
	  case $1 in
		*.tar.bz2)   tar xjf $1     ;;
		*.tar.gz)    tar xzf $1     ;;
		*.bz2)       bunzip2 $1     ;;
		*.rar)       unrar e $1     ;;
		*.gz)        gunzip $1      ;;
		*.tar)       tar xf $1      ;;
		*.tbz2)      tar xjf $1     ;;
		*.tgz)       tar xzf $1     ;;
		*.zip)       unzip $1       ;;
		*.Z)         uncompress $1  ;;
		*.7z)        7z x $1        ;;
		*)     echo "'$1' cannot be extracted via extract()" ;;
		 esac
	 else
		 echo "'$1' is not a valid file"
	 fi
}


#   ---------------------------------------
#   REMINDERS & NOTES
#   ---------------------------------------

#   remove_disk: spin down unneeded disk
#   ---------------------------------------
#   diskutil eject /dev/disk1s3

#   to change the password on an encrypted disk image:
#   ---------------------------------------
#   hdiutil chpass /path/to/the/diskimage

#   to mount a read-only disk image as read-write:
#   ---------------------------------------
#   hdiutil attach example.dmg -shadow /tmp/example.shadow -noverify

#   mounting a removable drive (of type msdos or hfs)
#   ---------------------------------------
#   mkdir /Volumes/Foo
#   ls /dev/disk*   to find out the device to use in the mount command)
#   mount -t msdos /dev/disk1s1 /Volumes/Foo
#   mount -t hfs /dev/disk1s1 /Volumes/Foo

#   to create a file of a given size: /usr/sbin/mkfile or /usr/bin/hdiutil
#   ---------------------------------------
#   e.g.: mkfile 10m 10MB.dat
#   e.g.: hdiutil create -size 10m 10MB.dmg
#   the above create files that are almost all zeros - if random bytes are desired
#   then use: ~/Dev/Perl/randBytes 1048576 > 10MB.dat

	

#   ---------------------------------------
#   Login Scripts
#   ---------------------------------------

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
