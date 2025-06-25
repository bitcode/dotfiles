# ============================================================================
# HOMEBREW ENVIRONMENT (must come first)
# ============================================================================
eval "$(/opt/homebrew/bin/brew shellenv)"

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export VISUAL="nvim"
export EDITOR="nvim"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export MANPAGER="/usr/bin/zsh -c 'col -b | nvim -c \"set ft=man ts=8 nomod nolist nonu noma\"'"
export MANWIDTH=999
export AUTOSWITCH_VIRTUAL_ENV_DIR=".virtualenv"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Create XDG directories if they don't exist
for dir in "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME"; do
  [[ ! -d "$dir" ]] && mkdir -p "$dir"
done

# ============================================================================
# PATH CONFIGURATION
# ============================================================================
# Python PATH - Dotsible managed
export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Development tools
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Remove duplicate PATH entries
export PATH=$(echo "$PATH" | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')

# Development environment variables
export GO111MODULE=on
export GOPATH="$HOME/go"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# Vim Mode Configuration
set -o vi
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
ZVM_REPLACE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK

# Aliases
alias cp_staged_diff='git diff --cached | xclip -selection clipboard'
alias multi_clip='~/dotfiles/scripts/multi_clip_xclip.sh'
alias gitcheck='~/dotfiles/scripts/gitcheck.sh'
alias new_repo='~/dotfiles/scripts/create_and_push_repo.sh'
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
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias lg='lazygit'

# Set the color of suggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"

# Change the keybinding to accept the current suggestion with Ctrl+J
bindkey '^J' autosuggest-accept

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh Plugins
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-fzf-history-search/zsh-fzf-history-search.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Theme
eval "$(starship init zsh)"

# FZF Configuration
source <(fzf --zsh)

# ============================================================================
# COMPLETION SYSTEM (run only once with proper caching)
# ============================================================================
setopt local_options extendedglob
autoload -Uz compinit

# Use XDG-compliant location for completion dump
export ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/.zcompdump"

# Check if .zcompdump is older than 24 hours or doesn't exist
if [[ -n $ZSH_COMPDUMP(#qN.mh+24) ]]; then
    print -P "%F{yellow}Compinit: Regenerating completion dump...%f"
    compinit -d "$ZSH_COMPDUMP"
else
    print -P "%F{green}Compinit: Loading completion from cache...%f"
    compinit -C -d "$ZSH_COMPDUMP"
fi

# Completion styling
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'




# ============================================================================
# ZOXIDE INITIALIZATION (after compinit)
# ============================================================================

# Initialize zoxide - Smart directory navigation with cd replacement
# This must come after compinit for proper functionality
if command -v zoxide >/dev/null 2>&1; then
    # Use --cmd cd to replace cd command with smart zoxide behavior
    # This provides automatic fallback to regular cd when no matches found
    eval "$(zoxide init --cmd cd zsh)"
    # echo "🧭 Zoxide smart directory navigation loaded"  # Commented out to prevent verbose output

    # Create zi alias for interactive mode (since --cmd cd creates cdi instead of zi)
    alias zi='cdi'
fi

# Note: With --cmd cd, zoxide creates:
# - cd() function (smart matching with fallback)
# - cdi() function (interactive mode)
# - zi is aliased to cdi for compatibility

# ============================================================================
# SMART DIRECTORY NAVIGATION (Zoxide)
# ============================================================================
# Initialize zoxide AFTER compinit for proper completion support
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# ============================================================================
# FZF CONFIGURATION
# ============================================================================
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_COMPLETION_TRIGGER="**"

# FZF Key Bindings
bindkey '^T' fzf-file-widget      # Ctrl+T for file search
bindkey '^R' fzf-history-widget   # Ctrl+R for history search
bindkey '\ec' fzf-cd-widget       # Alt+C for directory search

# Custom completion for common commands
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# ============================================================================
# ZSH OPTIONS
# ============================================================================
setopt HIST_VERIFY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt GLOB_COMPLETE
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt CORRECT

# Key bindings
bindkey -e  # Use emacs key bindings
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[3~' delete-char         # Delete
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[5~' up-line-or-history  # Page Up
bindkey '^[[6~' down-line-or-history # Page Down

# ============================================================================
# PERFORMANCE PROFILING (uncomment to debug startup time)
# ============================================================================
#end_time=$(date +%s%N)
#echo "Shell startup time: $((($end_time - $start_time) / 1000000)) ms"
#zprof



# BEGIN ANSIBLE MANAGED BLOCK - Oh My Zsh Plugins
# Oh My Zsh Configuration
export ZSH="/Users/mdrozrosario/.oh-my-zsh"

# Plugins configuration
plugins=(git sudo history colored-man-pages)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh
# END ANSIBLE MANAGED BLOCK - Oh My Zsh Plugins
# BEGIN ANSIBLE MANAGED BLOCK - Plugin Settings
# Plugin-specific configurations

# zsh-autosuggestions
if [[ -f /Users/mdrozrosario/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"
  ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line vi-end-of-line vi-add-eol)
  ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(vi-forward-word forward-word vi-forward-word-end forward-word-end vi-find vi-find-next)
  bindkey '^J' autosuggest-accept
fi

# zsh-history-substring-search
if [[ -f /Users/mdrozrosario/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=cyan,fg=white,bold"
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=magenta,fg=white,bold"
  HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS="i"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
fi

# zsh-syntax-highlighting (must be loaded last)
if [[ -f /Users/mdrozrosario/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
fi
# END ANSIBLE MANAGED BLOCK - Plugin Settings
# BEGIN ANSIBLE MANAGED BLOCK - Theme Configuration
# ZSH Theme Configuration
ZSH_THEME="robbyrussell"

# Theme-specific settings
# END ANSIBLE MANAGED BLOCK - Theme Configuration
# BEGIN ANSIBLE MANAGED BLOCK - Basic Aliases
# Basic Aliases
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
# END ANSIBLE MANAGED BLOCK - Basic Aliases
# BEGIN ANSIBLE MANAGED BLOCK - Conditional Aliases
# Conditional Aliases (only if commands exist)

# Enhanced ls aliases (if exa/lsd available)
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
  alias lt='lsd --tree'
elif command -v exa >/dev/null 2>&1; then
  alias ls='exa'
  alias ll='exa -l'
  alias la='exa -la'
  alias lt='exa --tree'
else
  alias ll='ls -l'
  alias la='ls -la'
fi

# Enhanced cat (if bat available)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
  alias catn='bat --style=plain'
fi

# Enhanced find (if fd available)
if command -v fd >/dev/null 2>&1; then
  alias find='fd'
fi

# Enhanced grep (if ripgrep available)
if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

# Enhanced top (if htop available)
if command -v htop >/dev/null 2>&1; then
  alias top='htop'
fi

# Enhanced du (if dust available)
if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi

# Enhanced ps (if procs available)
if command -v procs >/dev/null 2>&1; then
  alias ps='procs'
fi
# END ANSIBLE MANAGED BLOCK - Conditional Aliases
# BEGIN ANSIBLE MANAGED BLOCK - Utility Aliases
# Utility Aliases

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Quick directory listing
alias l='ls -CF'
alias dir='ls -la'

# Network utilities
alias ping='ping -c 5'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'

# System information
alias df='df -h'
alias free='free -h'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# File operations
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias path='echo -e ${PATH//:/\\n}'

# History
alias h='history'
alias hgrep='history | grep'

# Process management
alias j='jobs -l'

# Quick edits
alias zshconfig='${EDITOR:-vim} ~/.zshrc'
alias zshreload='source ~/.zshrc'
# END ANSIBLE MANAGED BLOCK - Utility Aliases
# BEGIN ANSIBLE MANAGED BLOCK - Utility Functions
# Utility Functions

# Extract function for various archive formats
extract() {
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

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Find and kill process by name
killp() {
  ps aux | grep -i $1 | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Quick backup function
backup() {
  cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}
}

# Weather function (requires curl)
weather() {
  curl -s "wttr.in/${1:-}"
}

# Quick note function
note() {
  echo "$(date): $*" >> "$HOME/notes.txt"
}

# Show notes
notes() {
  if [ -f "$HOME/notes.txt" ]; then
    cat "$HOME/notes.txt"
  else
    echo "No notes found. Use 'note <text>' to create one."
  fi
}
# END ANSIBLE MANAGED BLOCK - Utility Functions
# BEGIN ANSIBLE MANAGED BLOCK - Development Functions
# Development Functions

# Git functions
gclone() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

gcommit() {
  git add . && git commit -m "$1"
}

gpush() {
  git add . && git commit -m "$1" && git push
}

# Python virtual environment functions
venv() {
  if [ "$1" = "create" ]; then
    python3 -m venv "${2:-venv}"
  elif [ "$1" = "activate" ]; then
    source "${2:-venv}/bin/activate"
  elif [ "$1" = "deactivate" ]; then
    deactivate
  else
    echo "Usage: venv {create|activate|deactivate} [name]"
  fi
}

# Docker functions
dps() {
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

dexec() {
  docker exec -it "$1" /bin/bash
}

# Node.js functions
npmg() {
  npm list -g --depth=0
}

# Quick server function
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}
# END ANSIBLE MANAGED BLOCK - Development Functions
# BEGIN ANSIBLE MANAGED BLOCK - System Functions
# System Functions

# System information
sysinfo() {
  echo "System Information:"
  echo "=================="
  echo "Hostname: $(hostname)"
  echo "OS: $(uname -s)"
  echo "Kernel: $(uname -r)"
  echo "Architecture: $(uname -m)"
  echo "Uptime: $(uptime)"
  echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
  echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
}

# Process monitoring
psmem() {
  ps aux --sort=-%mem | head -n "${1:-10}"
}

pscpu() {
  ps aux --sort=-%cpu | head -n "${1:-10}"
}

# Network functions
myports() {
  netstat -tulanp | grep LISTEN
}

# File search functions
ff() {
  find . -type f -name "*$1*"
}

# Note: Renamed from fd() to fdir() to avoid conflict with fd binary (fast file finder)
fdir() {
  find . -type d -name "*$1*"
}
# END ANSIBLE MANAGED BLOCK - System Functions



# BEGIN ANSIBLE MANAGED BLOCK - Development Environment
# Development Environment

# Node.js/npm configuration
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
[[ -d "$NPM_CONFIG_PREFIX/bin" ]] && export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# Python configuration
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Go configuration
export GOPATH="$HOME/go"
[[ -d "$GOPATH/bin" ]] && export PATH="$GOPATH/bin:$PATH"

# Rust configuration
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Ruby configuration
[[ -d "$HOME/.gem/ruby" ]] && export PATH="$HOME/.gem/ruby/*/bin:$PATH"

# Java configuration
[[ -d "/usr/lib/jvm/default" ]] && export JAVA_HOME="/usr/lib/jvm/default"
[[ -d "/Library/Java/JavaVirtualMachines" ]] && export JAVA_HOME="/Library/Java/JavaVirtualMachines/*/Contents/Home"

# Docker configuration
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
# END ANSIBLE MANAGED BLOCK - Development Environment


# BEGIN ANSIBLE MANAGED BLOCK - NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# END ANSIBLE MANAGED BLOCK - NVM Configuration

# Created by `pipx` on 2025-06-15 06:41:36
export PATH="$PATH:/Users/mdrozrosario/.local/bin"
export PATH="$HOME/.dotnet/tools:$PATH"
