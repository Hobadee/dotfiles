# Here we will do stuff that we want setup across different shells.
# This should be loaded first by all shells so it can be overwritten if need be.

# Test and set the OS type
case $OSTYPE in
	linux-gnu)
		OS_LINUX=1
		;;
    cygwin)
		# POSIX compatibility layer and Linux environment emulation for Windows
		OS_CYGWIN=1
		;;
    msys)
		# Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
		OS_WIN=1
		;;
    darwin*)
		# Mac OSX
		OS_OSX=1
		;;
    freebsd*)
		# Free BSD?
		OS_BSD=1
		;;
    *)
		OS_UNKNOWN=1
		;;
esac


# Some additions to PATH
# Add personal binaries if they exist
if [[ -d ~/bin ]]; then
	export PATH="$PATH:$HOME/bin"					# Add ~/bin to PATH
fi
## Add composer binaries if they exist
if [[ -d ~/.composer/vendor/bin ]]; then
    export PATH="$PATH:$HOME/.composer/vendor/bin"	# Add composer binaries to path
fi
## Add MetaSploit binaries if they exist
if [[ -d /opt/metasploit-framework/bin ]]; then
    export PATH="$PATH:/opt/metasploit-framework/bin"
fi
## Add Ruby Gems if they exist.
### Note this is ruby-version specific.  Perhaps in the future we can
### check ruby version and auto-add?
if [[ -d ~/.gem/ruby/2.6.0/bin ]]; then
    export PATH=$PATH:$HOME/.gem/ruby/2.6.0/bin
fi
## Prefer BREW version of ruby over OSX
if [[ -d /usr/local/opt/ruby/bin ]]; then
    export PATH=/usr/local/opt/ruby/bin:$PATH
fi


# Directory coloring
if [[ $OS_OSX || $OS_BSD ]]; then
    export CLICOLOR=1
    export LSCOLORS=Gxfxcxdxbxegedabagacad
    #export LSCOLORS=ExFxBxDxCxegedabagacad
    
    ## Prefer GNU version, since it respects dircolors.
    if [[ -x $(command -v gls) ]]; then
      alias ls='() { $(whence -p gls) -Ctr --file-type --color=auto $@ }'
    else
      alias ls='() { $(whence -p ls) -CFtr $@ }'
    fi
fi


# Set default blocksize for ls, df, du
export BLOCKSIZE=1k



# color formatting for man pages
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'     # begin blink
export LESS_TERMCAP_so=$'\e[1;33;44m'  # begin reverse video
export LESS_TERMCAP_us=$'\e[1;37m'     # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export GROFF_NO_SGR=1                  # for konsole and gnome-terminal

export MANPAGER='less -s -M -R +Gg'




if [[ -x $(command -v notepad++) ]]; then
    export EDITOR="notepad++"
elif [[ -x $(command -v emacs) ]]; then
    export EDITOR="emacs"
elif [[ -x $(command -v nano) ]]; then
    export EDITOR="nano"
else
    # No editor I like... :-/
    EDITOR=
fi


termcolors(){
  for i in {0..255}; do
    print -Pn "%${i}F${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'};
  done ;
}


#   -----------------------------
#   General Aliases
#   -----------------------------
alias ll='ls -lahF'									# Preferred 'ls' implementation
alias cp='cp -iv'									# Preferred 'cp' implementation
alias mv='mv -iv'									# Preferred 'mv' implementation
alias rm='rm -i'									# Preferred 'rm' implementation
alias mkdir='mkdir -pv'								# Preferred 'mkdir' implementation
alias lless='CLICOLOR_FORCE=1 ll -G | less -R'		# lless:	Colorised 'ls' piping to colorized 'less'
alias cls='clear;ls'								# cls:		Clear screen and 'ls'
alias cll='clear;ll'								# cll:		Clear screen and 'll'
alias path='echo -e ${PATH//:/\\n}'					# path:		Echo all executable Paths
alias DT='tee ~/Desktop/terminalOut.txt'			# DT:		Pipe content to file on MacOS Desktop
alias profile='declare -F | sed "/iterm2/d" | sed "s/declare -f //"; alias | sed "s/alias //" | sed "s/=.*//"'
alias clearSB="printf '\e[3J'"						# clearSB:	Clear the Scrollback history.  iTerm2.  Others?
alias ext4fuse="ext4fuse -o allow_other"
mcd(){ mkdir -p "$1" && cd "$1" ; }					# mcd:		Make directory and CD into it.
edit(){ $EDITOR "$1" ; }								# edit:		Open file for editing using $EDITOR

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

alias qfind="find . -name "                 # qfind:    Quickly search for file
ff () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
ffs () { /usr/bin/find . -name "$@*" ; }  # ffs:      Find file whose name starts with a given string
ffe () { /usr/bin/find . -name "*$@" ; }  # ffe:      Find file whose name ends with a given string


#   ---------------------------
#   PROCESS MANAGEMENT
#   ---------------------------

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#   my_ps: List processes owned by my user:
#   ------------------------------------------------------------
my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command ; }


#   ---------------------------
#   NETWORKING
#   ---------------------------

# New versions of dig don't work with MS DNS unless you specify +nocookie
alias dig='dig +nocookie'

# myip:			Public facing IP Address
myip () {
    dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'
}

# netCons:		Show all open TCP/IP sockets
alias netCons='lsof -i'

# lsock:		Display open sockets
alias lsock='sudo /usr/sbin/lsof -i -P'

# lsockU:		Display only open UDP sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'

# lsockT:		Display only open TCP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'

# ipInfo:		Get info on connections for interface $1
ipInfo(){ ipconfig getpacket "$1" ; }

# openPorts:	All listening connections
alias openPorts='sudo lsof -i | grep LISTEN'

# showBlocked:	All ipfw rules inc/ blocked IPs
alias showBlocked='sudo ipfw list'

#   ii:  display useful host related informaton
#   -------------------------------------------------------------------
ii() {
    echo -e "\nYou are logged on ${RED}$HOST"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Current network location :$NC " ; scselect
    echo -e "\n${RED}Public facing IP Address :$NC " ;myip
    #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
    echo
}

chip() { ping -c 1 -t 1 "$@" 2>1 >/dev/null ; }


#   ---------------------------------------
#   WEB DEVELOPMENT
#   ---------------------------------------

#   httpHeaders:  Grabs headers from web page
#   -------------------------------------------------------------------
httpHeaders () { /usr/bin/curl -I -L "$@" ; }

#   httpDebug:  Download a web page and show info on what took time
#   -------------------------------------------------------------------
httpDebug () { /usr/bin/curl "$@" -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\n" ; }

# https://cshorde.wordpress.com/2013/11/10/the-struggles-with-xampp-oracle-and-oci8-on-mac/
#export DYLD_LIBRARY_PATH="/Applications/XAMPP/xamppfiles/lib:/Applications/XAMPP/xamppfiles/lib/instantclient-11.2.0.3.0"


# Change some OSX stuff, if we are on OSX
if [[ $OS_OSX ]]; then
    export COPYFILE_DISABLE=true						# Prevents TAR from adding stupid extra files
    
    alias f='open -a Finder ./'							# Opens current directory in MacOS Finder
    alias plist='plutil -convert xml1 -o /dev/stdout'	# plist:	Show a plist file in XML format
    trash(){ command mv "$@" ~/.Trash ; }				# trash:	Moves files to the OSX Trash
    ql () { qlmanage -p "$*" >& /dev/null; }			# ql:		Opens any file in MacOS Quicklook Preview
    
    #   spotlight: Search for a file using MacOS Spotlight's metadata
    #   -----------------------------------------------------------
    spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }
    
    alias flushDNS='dscacheutil -flushcache'            # flushDNS:	Flush out the DNS Cache
    #alias flushDNS='sudo killall -HUP mDNSResponder'	# flushDNS:	Alternate flush of the DNS Cache
    
    #   cleanupDS:  Recursively delete .DS_Store files
    #   -------------------------------------------------------------------
    alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
    
    #   finderShowHidden:   Show hidden files in Finder
    #   finderHideHidden:   Hide hidden files in Finder
    #   -------------------------------------------------------------------
    alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
    alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'
    
    eject () { diskutil eject "$@" ; }					# Eject disk
    unmount () { diskutil unmountAll "$@" ; }			# Unmounts all volumes of a disk
fi


if [[ -x $(command -v fortune) ]]; then
    echo ""
    fortune -s
    echo ""
fi

gam() { "$HOME/bin/gam/gam" "$@" ; }
