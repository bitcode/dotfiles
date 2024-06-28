# Start profiling
#zmodload zsh/zprof
#start_time=$(date +%s%N)

# Environment and Path Variables
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export PATH="$HOME/.cargo/bin:$PATH"
export PYTHONPATH="/usr/bin/python3"
export VISUAL="nvim"
export EDITOR="nvim"
export TERM="xterm-256color"
export MANPAGER="/usr/bin/zsh -c 'col -b | nvim -c \"set ft=man ts=8 nomod nolist nonu noma\"'"
export MANWIDTH=999
export AUTOSWITCH_VIRTUAL_ENV_DIR=".virtualenv"
export XDG_CONFIG_HOME="$HOME/.config/"
export FZF_DEFAULT_COMMAND="zoxide query --list"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export MANPATH="/home/bit/.local/share/man:/usr/local/share/man:/home/bit/man/man-intrinsics"

# History Configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Vim Mode Configuration
set -o vi
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
ZVM_REPLACE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK

# Aliases
alias multi_clip='~/dotfiles/scripts/multi_clip_xclip.sh'
alias gitcheck='~/dotfiles/scripts/gitcheck.sh'
alias tls='tmux ls'
alias rc='rustc'
alias dc='cd ..'
alias tsource='tmux source-file ~/.tmux.conf'
alias c='clear'
alias grg='go run main.go'
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias lz='ls -alZ | more'
alias py='python3'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias lg='lazygit'
alias python='/usr/bin/python3'

# Initialize zoxide normally
eval "$(zoxide init zsh)"

# Override 'cd' to behave as 'zi'
cd() {
  if [ $# -eq 0 ]; then
    builtin cd
  else
    zi "$@"
  fi
}

# Set the color of suggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"

# Change the keybinding to accept the current suggestion with Ctrl+J
bindkey '^J' autosuggest-accept

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh Plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/zsh-fzf-history-search/zsh-fzf-history-search.zsh
source ~/.zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Theme
eval "$(starship init zsh)"

# Ensure compinit is run only once with caching
setopt local_options extendedglob
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
    compinit -C
fi

# Background refresh to update .zcompdump file
(autoload -Uz compinit && compinit -d "${ZDOTDIR:-$HOME}/.zcompdump" &)

# At the very end of .zshrc
#end_time=$(date +%s%N)
#echo "Shell startup time: $((($end_time - $start_time) / 1000000)) ms"
#zprof
