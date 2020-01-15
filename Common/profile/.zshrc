# zshrc loads after zprofile

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE


# Check if zplug is installed and install if not
if [[ ! -d ~/.zplug ]]; then
    RED="\033[1;31m"
    NOCOLOR="\033[0m"
    echo "${RED}Please wait... Installing zplug...${NOCOLOR}"
    git clone https://github.com/zplug/zplug ~/.zplug
    source ~/.zplug/init.zsh && zplug update
    zplug "zplug/zplug", hook-build:"zplug --self-manage"
fi
source ~/.zplug/init.zsh


# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"


# Laregely stolen from:
# https://github.com/tonylambiris/dotfiles/blob/master/dot.zshrc


# --------------------------------------------------
# Load Themes
# --------------------------------------------------
zplug "Powerlevel9k/powerlevel9k", use:powerlevel9k.zsh-theme, from:github, at:next, as:theme


# --------------------------------------------------
# Load Plugins
# --------------------------------------------------
zplug "chrissicool/zsh-256color"                                            # Add more colors to terminal
zplug "zdharma/zsh-diff-so-fancy"                                           # Prettify `diff`
zplug "peco/peco", as:command, from:gh-r, use:"*${(L)$(uname -s)}*amd64*"   # Simplistic interactive filtering tool
zplug "b4b4r07/enhancd", use:init.sh                                        # Enhanced `cd`
zplug "arzzen/calc.plugin.zsh"                                              # Simple zsh calculator
zplug "zsh-users/zsh-completions"                                           # Better tab-completion for many commands
zplug "zsh-users/zsh-autosuggestions"                                       # Suggest as-you-type
zplug "hlissner/zsh-autopair", defer:2                                      # Auto-close and delete matching delimiters in zsh

# A command-line fuzzy finder
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf, use:"*${(L)$(uname -s)}*amd64*"
zplug "junegunn/fzf", use:"shell/*.zsh"

# Better ZHS history
# We should only do this if we have sqlite installed, otherwise terminal becomes nearly unusable
# Check for sqlite
if [[ -x $(command -v sqlite3) ]]; then
    HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
    zplug "larkery/zsh-histdb", use:"{sqlite-history,histdb-interactive}.zsh", hook-load:"histdb-update-outcome"
    autoload -Uz add-zsh-hook       # Needed for larkery/zsh-histdb
    add-zsh-hook precmd histdb-update-outcome
fi

# Plugins from Oh-My-ZSH
zplug "plugins/ansible",        from:oh-my-zsh
zplug "plugins/aws",            from:oh-my-zsh
zplug "plugins/docker",         from:oh-my-zsh
zplug "plugins/extract",        from:oh-my-zsh
zplug "plugins/git",            from:oh-my-zsh
zplug "plugins/git-extras",     from:oh-my-zsh
zplug "plugins/git-flow",       from:oh-my-zsh
zplug "plugins/gitignore",      from:oh-my-zsh
zplug "plugins/kubectl",        from:oh-my-zsh
zplug "plugins/laravel",        from:oh-my-zsh
zplug "plugins/npm",            from:oh-my-zsh
zplug "plugins/vscode",         from:oh-my-zsh
zplug "plugins/encode64",       from:oh-my-zsh
zplug "plugins/tmux",           from:oh-my-zsh
zplug "plugins/urltools",       from:oh-my-zsh
zplug "plugins/ssh-agent",      from:oh-my-zsh

if [[ $OSTYPE = (darwin)* ]]; then
    zplug "lib/clipboard",      from:oh-my-zsh
    zplug "plugins/osx",        from:oh-my-zsh
    zplug "plugins/brew",       from:oh-my-zsh, if:"(( $+commands[brew] ))"
fi


# --------------------------------------------------
# Shell Options
# --------------------------------------------------

setopt autocd                   # Allow changing directories without `cd`
setopt append_history           # Dont overwrite history
setopt auto_list
setopt auto_menu
setopt auto_pushd
setopt extended_history         # Also record time and duration of commands.
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Dont display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.
setopt hist_ignore_space        # Ignore commands that start with space.
setopt inc_append_history
setopt interactive_comments
setopt no_beep
setopt no_hist_beep
setopt no_list_beep
setopt magic_equal_subst
setopt notify
setopt print_eight_bit
setopt print_exit_value
setopt prompt_subst
setopt pushd_ignore_dups
setopt share_history            # Share history between multiple shells
setopt transient_rprompt


# --------------------------------------------------
# Plugin Options
# --------------------------------------------------


if zplug check "plugins/ssh-agent"; then
    # Set key lifetime to 1 hour
    zstyle :omz:plugins:ssh-agent lifetime 1h
    # Force *no* SSH-keys loaded; we want to load via AddKeysToAgent so we aren't prompted on login
    zstyle :omz:plugins:ssh-agent identities ""
    # Enable SSH forwarding.
    zstyle :omz:plugins:ssh-agent agent-forwarding on
fi

# Only load the histdb plugin config if SQLITE3 exists!
if [[ $(zplug check "larkery/zsh-histdb") == 0 && -x $(command -v sqlite3) ]]; then
    if [ ! -f "$HOME/.histdb/zsh-history.db" ]; then
        echo "Import your old zsh history with github.com/drewis/go-histdbimport"
    fi

    _zsh_autosuggest_strategy_histdb_top_here() {
        local query="select commands.argv from
                        history left join commands on history.command_id = commands.rowid
                        left join places on history.place_id = places.rowid
                        where places.dir LIKE '$(sql_escape $PWD)%'
                        and commands.argv LIKE '$(sql_escape $1)%'
                        group by commands.argv order by count(*) desc limit 1"
        suggestion=$(_histdb_query "$query")
    }

    ZSH_AUTOSUGGEST_STRATEGY=histdb_top_here
    #bindkey '^r' _histdb-isearch
fi

if zplug check "junegunn/fzf-bin"; then
    export FZF_DEFAULT_OPTS="--height 40% --reverse --border --inline-info --color=dark,bg+:235,hl+:10,pointer:5"
fi

if zplug check "zsh-users/zsh-autosuggestions"; then
    #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=075'
    #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=162'
fi

if zplug check "b4b4r07/enhancd"; then
    ENHANCD_FILTER="fzf:peco:percol"
    ENHANCD_COMMAND="c"
fi

if zplug check "Powerlevel9k/powerlevel9k"; then

    if [[ $OSTYPE == darwin* ]]; then
        zsh_wifi_signal(){
            local output=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I)
            local airport=$(echo $output | grep 'AirPort' | awk -F': ' '{print $2}')

            if [ "$airport" = "Off" ]; then
                    local color='%F{black}'
                    echo -n "%{$color%}Wifi Off"
            else
                    local ssid=$(echo $output | grep ' SSID' | awk -F': ' '{print $2}')
                    local speed=$(echo $output | grep 'lastTxRate' | awk -F': ' '{print $2}')
                    local color='%F{green}'

                    [[ $speed -gt 100 ]] && color='%F{green}'
                    [[ $speed -lt 50 ]] && color='%F{red}'

                    echo -n "%{$color%}$speed Mbps \uf1eb%{%f%}" # removed char not in my PowerLine font
            fi
        }
    elif [[ -x $(command -v nmcli) ]]; then
        zsh_wifi_signal(){
            local signal=$(nmcli device wifi | grep yes | awk '{print $8}')
            local color='%F{yellow}'
            [[ $signal -gt 75 ]] && color='%F{green}'
            [[ $signal -lt 50 ]] && color='%F{red}'
            echo -n "%{$color%}\uf230  $signal%{%f%}" # \uf230 is 
        }
    else
        zsh_wifi_signal(){
            # No WiFi or no way to find WiFi signal.  Null function.
        }
    fi

    #DEFAULT_USER=$USER

    # Easily switch primary foreground/background colors
    #DEFAULT_FOREGROUND=038 DEFAULT_BACKGROUND=024 PROMPT_COLOR=038
    #DEFAULT_FOREGROUND=006 DEFAULT_BACKGROUND=235 PROMPT_COLOR=173
    #DEFAULT_FOREGROUND=198 DEFAULT_BACKGROUND=090 PROMPT_COLOR=173
    #DEFAULT_FOREGROUND=235 DEFAULT_BACKGROUND=159 PROMPT_COLOR=173
    #DEFAULT_FOREGROUND=123 DEFAULT_BACKGROUND=059 PROMPT_COLOR=183
    #DEFAULT_FOREGROUND=159 DEFAULT_BACKGROUND=238 PROMPT_COLOR=173
    DEFAULT_FOREGROUND=159 DEFAULT_BACKGROUND=239 PROMPT_COLOR=172
    #DEFAULT_COLOR=$DEFAULT_FOREGROUND
    DEFAULT_COLOR="clear"

    P9K_MODE="nerdfont-complete"
    P9K_STATUS_VERBOSE=false
    #P9K_DIR_SHORTEN_LENGTH=1
    #P9K_SHORTEN_STRATEGY="truncate_right"

    P9K_DIR_OMIT_FIRST_CHARACTER=false

    P9K_CONTEXT_ALWAYS_SHOW=true
    P9K_CONTEXT_ALWAYS_SHOW_USER=false

    #P9K_CONTEXT_TEMPLATE="\uF109 %m"

    #P9K_LEFT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 2 ))}|%f"
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 2 ))}|%f"

    #P9K_LEFT_SUBSEGMENT_SEPARATOR="%F{$DEFAULT_BACKGROUND}\ue0b0%f"
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{$DEFAULT_BACKGROUND}\ue0b2%f"
    P9K_LEFT_SUBSEGMENT_SEPARATOR_ICON="%F{232}\uE0BD%f"
    P9K_RIGHT_SUBSEGMENT_SEPARATOR_ICON="%F{232}\uE0BD%f"
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{000}%f"
    #P9K_LEFT_SUBSEGMENT_SEPARATOR="%F{000}／%f" # 
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{000}／%f" #
    #P9K_LEFT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 3 ))}／%f"
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{$(( $DEFAULT_BACKGROUND - 3 ))}／%f"
    #P9K_LEFT_SUBSEGMENT_SEPARATOR="%F{$DEFAULT_FOREGROUND}\uE0B0%f"
    #P9K_RIGHT_SUBSEGMENT_SEPARATOR="%F{$DEFAULT_FOREGROUND}\uE0B3%f"

    #P9K_LEFT_SEGMENT_SEPARATOR="\uE0B4"
    #P9K_RIGHT_SEGMENT_SEPARATOR="\uE0B6"
    P9K_LEFT_SEGMENT_SEPARATOR_ICON='▓▒░'
    P9K_RIGHT_SEGMENT_SEPARATOR_ICON='░▒▓'
    #P9K_LEFT_SEGMENT_SEPARATOR="\uE0BC\u200A"
    #P9K_RIGHT_SEGMENT_SEPARATOR="\u200A\uE0BA"
    #P9K_LEFT_SEGMENT_SEPARATOR="\uE0BC"
    #P9K_RIGHT_SEGMENT_SEPARATOR="\uE0BA"
    #P9K_LEFT_SEGMENT_SEPARATOR="%F{$DEFAULT_BACKGROUND}\uE0BC%f"
    #P9K_RIGHT_SEGMENT_SEPARATOR="%F{$DEFAULT_BACKGROUND}\uE0BA%f"

    P9K_PROMPT_ON_NEWLINE=true
    P9K_RPROMPT_ON_NEWLINE=false

    P9K_STATUS_VERBOSE=true
    P9K_STATUS_CROSS=true
    P9K_PROMPT_ADD_NEWLINE=true

    P9K_MULTILINE_FIRST_PROMPT_PREFIX_ICON="%F{$PROMPT_COLOR}%f"
    P9K_MULTILINE_LAST_PROMPT_PREFIX_ICON="%F{$PROMPT_COLOR}➜ %f"
    #P9K_MULTILINE_LAST_PROMPT_PREFIX_ICON="%F{$PROMPT_COLOR}⇢ ➜  %f"
    #P9K_MULTILINE_LAST_PROMPT_PREFIX_ICON="%F{$PROMPT_COLOR} ┄⇢ %f"

    P9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir_writable dir vcs root_indicator)
    P9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs command_execution_time history time custom_wifi_signal ram load_joined battery)

    P9K_MODE='nerdfont-complete'

    P9K_VCS_GIT_GITHUB_ICON=""
    P9K_VCS_GIT_BITBUCKET_ICON=""
    P9K_VCS_GIT_GITLAB_ICON=""
    P9K_VCS_GIT_ICON=""

    P9K_HISTORY_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_HISTORY_FOREGROUND="cyan1"

    P9K_BATTERY_LEVEL_BACKGROUND=($DEFAULT_BACKGROUND)

    P9K_VCS_CLEAN_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_VCS_CLEAN_FOREGROUND="010"

    P9K_VCS_MODIFIED_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_VCS_MODIFIED_FOREGROUND="011"

    P9K_VCS_UNTRACKED_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_VCS_UNTRACKED_FOREGROUND="012"
    P9K_VCS_UNTRACKED_FOREGROUND="011"

    P9K_VCS_SHORTEN_STRATEGY="truncate_middle"

    P9K_RAM_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_RAM_FOREGROUND="white"

    P9K_LOAD_CRITICAL_BACKGROUND="yellow"
    P9K_LOAD_WARNING_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_LOAD_NORMAL_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_LOAD_CRITICAL_FOREGROUND="red"
    P9K_LOAD_WARNING_FOREGROUND="yellow"
    P9K_LOAD_NORMAL_FOREGROUND="white"
    P9K_LOAD_CRITICAL_VISUAL_IDENTIFIER_COLOR="red"
    P9K_LOAD_WARNING_VISUAL_IDENTIFIER_COLOR="yellow"
    P9K_LOAD_NORMAL_VISUAL_IDENTIFIER_COLOR="green"

    P9K_DIR_HOME_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_DIR_HOME_FOREGROUND="158"
    P9K_DIR_HOME_SUBFOLDER_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_DIR_HOME_SUBFOLDER_FOREGROUND="158"
    P9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="red"
    P9K_DIR_DEFAULT_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_DIR_DEFAULT_FOREGROUND="158"
    P9K_DIR_ETC_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_DIR_ETC_FOREGROUND="158"
    P9K_DIR_NOT_WRITABLE_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_DIR_NOT_WRITABLE_FOREGROUND="158"

    P9K_ROOT_INDICATOR_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_ROOT_INDICATOR_FOREGROUND="red"

    P9K_STATUS_OK_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_STATUS_OK_FOREGROUND="green"
    P9K_STATUS_ERROR_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_STATUS_ERROR_FOREGROUND="red"

    #P9K_TIME_FORMAT="%D{%H:%M:%S \uf017}" #  Jun 15  09:32
    P9K_TIME_ICON="\uF017" # 
    #P9K_TIME_BACKGROUND="$(( $DEFAULT_BACKGROUND - 2 ))"
    P9K_TIME_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_TIME_FOREGROUND="183"

    P9K_COMMAND_EXECUTION_TIME_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_COMMAND_EXECUTION_TIME_FOREGROUND="183"
    P9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
    P9K_COMMAND_EXECUTION_TIME_PRECISION=1

    P9K_BACKGROUND_JOBS_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_BACKGROUND_JOBS_FOREGROUND="123"

    P9K_USER_DEFAULT_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_USER_DEFAULT_FOREGROUND="cyan"
    P9K_USER_SUDO_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_USER_SUDO_FOREGROUND="magenta"
    P9K_USER_ROOT_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_USER_ROOT_FOREGROUND="red"
    P9K_USER_DEFAULT_ICON="\uF415" # 
    P9K_USER_ROOT_ICON=$'\uFF03' # ＃

    P9K_CONTEXT_TEMPLATE="\uF109 %m"
    #P9K_CONTEXT_TEMPLATE="\uF109 %m"
    P9K_CONTEXT_DEFAULT_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_CONTEXT_DEFAULT_FOREGROUND="$DEFAULT_FOREGROUND"
    P9K_CONTEXT_DEFAULT_FOREGROUND="123"
    P9K_CONTEXT_SUDO_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_CONTEXT_SUDO_FOREGROUND="$DEFAULT_FOREGROUND"
    P9K_CONTEXT_SUDO_FOREGROUND="123"
    P9K_CONTEXT_REMOTE_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_CONTEXT_REMOTE_FOREGROUND="$DEFAULT_FOREGROUND"
    P9K_CONTEXT_REMOTE_FOREGROUND="123"
    P9K_CONTEXT_REMOTE_SUDO_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_CONTEXT_REMOTE_SUDO_FOREGROUND="$DEFAULT_FOREGROUND"
    P9K_CONTEXT_REMOTE_SUDO_FOREGROUND="123"
    P9K_CONTEXT_ROOT_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_CONTEXT_ROOT_FOREGROUND="$DEFAULT_FOREGROUND"
    P9K_CONTEXT_ROOT_FOREGROUND="123"

    P9K_HOST_LOCAL_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_HOST_LOCAL_FOREGROUND="cyan"
    P9K_HOST_REMOTE_BACKGROUND="$DEFAULT_BACKGROUND"
    #P9K_HOST_REMOTE_FOREGROUND="magenta"
    P9K_HOST_LOCAL_ICON="\uF109 " # 
    P9K_HOST_REMOTE_ICON="\uF489 "  # 

    P9K_SSH_ICON="\uF489 "  # 
    #P9K_SSH_BACKGROUND="$(( $DEFAULT_BACKGROUND - 2 ))"
    P9K_SSH_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_SSH_FOREGROUND="212"
    #P9K_OS_ICON_BACKGROUND="$(( $DEFAULT_BACKGROUND - 2 ))"
    P9K_OS_ICON_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_OS_ICON_FOREGROUND="212"
    #P9K_SHOW_CHANGESET=true

    P9K_CUSTOM_WIFI_SIGNAL="zsh_wifi_signal"
    P9K_CUSTOM_WIFI_SIGNAL_BACKGROUND="$DEFAULT_BACKGROUND"
    P9K_CUSTOM_WIFI_SIGNAL_FOREGROUND="cyan1"
fi


# --------------------------------------------------
# Load Plugins
# --------------------------------------------------

if ! zplug check; then
    printf "Install plugins? [y/N]: "
    if read -q; then
        echo
        zplug install
        source ~/.zshrc
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load


# --------------------------------------------------
# Completion
# --------------------------------------------------
zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

zstyle ':completion:*' completer _expand _complete _ignored _approximate
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{yellow}%d%f%u'
#zstyle ':completion:*:*:git:*' script ~/.git-completion.sh

zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# case-insensitive (all), partial-word and then substring completion
zstyle ":completion:*" matcher-list \
    "m:{a-zA-Z}={A-Za-z}" \
    "r:|[._-]=* r:|=*" \
    "l:|=* r:|=*"

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"


# --------------------------------------------------
# Addendum
# --------------------------------------------------

# M-f/M-b and other commands should stop on dirs and other deliminators
# Tell ZSH that they *aren't* parts of words by *removing* them.
# Default:
# WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
WORDCHARS='*?[]~=&;!#$%^(){}<>'

# If iTerm2 integration exists, enable it.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
