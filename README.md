# dotfiles
My dotfiles

To bootstrap:
```
curl https://hobadee.kincl.net/dotfiles.sh | sh
```

## Todo
- Replace all direct binary references to dynamic references.  (`$(command -v $CMD)`)
- Make SSH detection better
- Spawn tmux terminal on SSH session
- Kill SSH session on tmux termination
- Fix `termcolors` function
- See if we can detect a non-emulated terminal or the font used.  If so, set `typeset -g POWERLEVEL9K_MODE=compatible` in `.p10k.zsh`
