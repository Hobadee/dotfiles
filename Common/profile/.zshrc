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
#zplug "Powerlevel9k/powerlevel9k", use:powerlevel9k.zsh-theme, from:github, at:next, as:theme
zplug "romkatv/powerlevel10k", as:theme, depth:1

if zplug check "romkatv/powerlevel10k"; then
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
elif zplug check "Powerlevel9k/powerlevel9k"; then
    [[ -f ~/.p9k.zsh ]] && source ~/.p9k.zsh
fi


# --------------------------------------------------
# Load Plugins
# --------------------------------------------------

# -------------------------
# Misc Plugins
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
# We should only do this if we have sqlite installed, otherwise terminal becomes nearly unusable with errors
# Check for sqlite
if [[ -x $(command -v sqlite3) ]]; then
    if [[ $OS_OSX ]]; then
       HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')
    fi
    zplug "larkery/zsh-histdb", use:"{sqlite-history,histdb-interactive}.zsh", hook-load:"histdb-update-outcome"
    autoload -Uz add-zsh-hook       # Needed for larkery/zsh-histdb
fi

# -------------------------
# Plugins from Oh-My-ZSH
zplug "plugins/ansible",        from:oh-my-zsh      # Adds several aliases for ansible
zplug "plugins/aws",            from:oh-my-zsh      # Completion support for awscli
zplug "plugins/docker",         from:oh-my-zsh      # Completion for docker
zplug "plugins/extract",        from:oh-my-zsh      # Wrapper to extract any archive
zplug "plugins/git",            from:oh-my-zsh      # Add many aliases for git
zplug "plugins/git-extras",     from:oh-my-zsh      # Completion support for some git-extras commands
zplug "plugins/git-flow",       from:oh-my-zsh      # Completion and aliases for git-flow
zplug "plugins/gitignore",      from:oh-my-zsh      # Gitignore.io from the command line
zplug "plugins/kubectl",        from:oh-my-zsh      # Completion and some aliases for kubectl
zplug "plugins/laravel",        from:oh-my-zsh      # Completion and aliases for laravel
zplug "plugins/npm",            from:oh-my-zsh      # Completion and aliases for npm
zplug "plugins/vscode",         from:oh-my-zsh      # Aliases for VS Code
zplug "plugins/encode64",       from:oh-my-zsh      # Encode/Decode Base64
zplug "plugins/tmux",           from:oh-my-zsh      # Aliases for tmux
zplug "plugins/urltools",       from:oh-my-zsh      # urlencode/urldecode
zplug "plugins/ssh-agent",      from:oh-my-zsh      # Auto-start SSH-Agent

if [[ $OSTYPE = (darwin)* ]]; then
    zplug "lib/clipboard",      from:oh-my-zsh                                  # OSX Clipboard copy/paste
    zplug "plugins/osx",        from:oh-my-zsh                                  # OSX commands
    zplug "plugins/brew",       from:oh-my-zsh, if:"(( $+commands[brew] ))"     # Aliases for brew
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

# The git plugin sets a "gam" alias which interferes which the `gam` application I use for GSuite management
unalias gam

# If iTerm2 integration exists, enable it.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
