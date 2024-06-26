export ZSH="/home/bit/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
export ZSH_THEME="powerlevel10k/powerlevel10k"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:/opt/gradle/gradle-8.7/bin"
export PATH="$PATH:/usr/local/bin/geckodriver"
export PATH="$PATH:/usr/local/bin/alacritty"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
#eval "$(pyenv virtualenv-init -)"
export PYTHONPATH="/usr/bin/python3"
export VISUAL="nvim"
export EDITOR="nvim"
#export BROWSER="/usr/bin/firefox"
export TERM="xterm-256color"
export MANPAGER="/usr/bin/zsh -c 'col -b | nvim -c \"set ft=man ts=8 nomod nolist nonu noma\"'"
#export MANPAGER=less
export MANWIDTH=999
export AUTOSWITCH_VIRTUAL_ENV_DIR=".virtualenv"
export XDG_CONFIG_HOME="$HOME/.config/"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
export FZF_DEFAULT_COMMAND="zoxide query --list"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"
export LD_LIBRARY_PATH="/home/bit/.pyenv/versions/3.12.2/lib/:$LD_LIBRARY_PATH"
export MANPATH="/home/bit/.local/share/man:/home/bit/.pyenv/man:/usr/share/man:/home/bit/.config/nvm/versions/node/v20.12.2/share/man:/usr/local/share/man:/home/bit/man/man-intrinsics"
<<<<<<< Updated upstream
=======
#export NVIM_LOG_LEVEL=debug
source "$NVM_DIR/nvm.sh"
source "$NVM_DIR/bash_completion"
>>>>>>> Stashed changes
source ~/dotfiles/scripts/gdmux.sh

# Plugin Configuration
plugins=(
  git
  pip
  history
  node
  npm
  docker
  sudo
  tmux
  tmuxinator
  taskwarrior
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
  zsh-history-substring-search
  virtualenv
  zsh-fzf-history-search
)


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
alias printCanon='lp -d Canon_MF260_Series_UFRII_LT'
alias py='python3'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias lg='lazygit'
alias python='/usr/bin/python3'
alias askollama='ask --model=orca2'
alias python='/home/bit/.pyenv/shims/python'

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

# SiteMap Script
sitemap(){
    lynx -dump "http://hackerone.com" | sed -n '/^References$/,$p' | grep -E '[[:digit:]]+\.' | awk '{print $2}' | cut -d\? -f1 | sort | uniq
}

# Custom Functions for Bug Bounty and Tools
s3ls(){ aws s3 ls s3://$1; }
s3cp(){ aws s3 cp $2 s3://$1; }
certprobe(){ curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt; }
dirsearch(){ python3 ~/tools/dirsearch/dirsearch.py -u $1 -e $2 -t 50 -b; }
sqlmap(){ python ~/tools/sqlmap*/sqlmap.py -u $1; }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
zvm_tmux_cursor_config() {
  if [ -n "$TMUX" ]; then
    ZVM_CURSOR_STYLE_ENABLED=false
  else
    ZVM_CURSOR_STYLE_ENABLED=true
  fi
}

zvm_tmux_cursor_config

# Change cursor shape in tmux based on vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q' # use block cursor
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]]; then
    echo -ne '\e[5 q' # use beam cursor
  fi
}
zle -N zle-keymap-select

function zle-line-init {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne '\e[5 q' # use beam cursor
}
zle -N zle-line-init

# Use vim keys in tab completion menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'c' accept-line
