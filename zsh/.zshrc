# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/home/bit/.oh-my-zsh"
ZSH_THEME=powerlevel10k/powerlevel10k
# Uncomment the following line to display red dots whilst waiting for completion.
 COMPLETION_WAITING_DOTS="true"
plugins=(
  vscode
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
  zsh-vim-mode
  kubectl
  zsh_codex
)
#ZSH_TMUX_AUTOSTART='true'
source $ZSH/oh-my-zsh.sh
ZSH_DISABLE_COMPFIX='true'
export LC_CTYPE=en_US.UTF-8
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
export PATH=$PATH:/usr/local/go/bin
source $HOME/.cargo/env
export PATH=$PATH:/usr/bin/node
export PATH=$PATH:/home/bit/.config/coc/extensions/node_modules/coc-clangd
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/lib
export VISUAL=nvim
export EDITOR=nvim
export PATH=$PATH:/home/bit/.local/bin
export PYTHONPATH=/usr/bin/python3
export BROWSER=/usr/bin/chromium # for web-browser
export PATH=$PATH:/bin/lua-language-server
#------- Aliases ---------

alias tls='tmux ls'
alias win='cd /mnt/c/Users/mylam'
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
set -o vi
alias py='python3'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'

#------- Vim Mode Cursor Styling ---

MODE_CURSOR_VIINS="#00ff00 blinking bar"
MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #ff0000"
MODE_CURSOR_VICMD="green block"
MODE_CURSOR_SEARCH="#ff00ff steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #00ffff"

#------- swap caps with escape ---

setxkbmap -option caps:swapescape

#------- zsh_codex ---

bindkey '^X' create_completion 

#----- Recon Bash Scripts -----
 
certspotter(){
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1
} #h/t Michiel Prins

crtsh(){
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u
}

certnmap(){
curl https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1  | nmap -T5 -Pn -sS -i - -$
} #h/t Jobert Abma

certbrute(){
cat $1.txt | while read line; do python3 dirsearch.py -e . -u "https://$line"; done
}

ipinfo(){
curl http://ipinfo.io/$1
}

#------SiteMap Script -----

sitemap(){
lynx -dump "http://hackerone.com" | sed -n '/^References$/,$p' | grep -E '[[:digit:]]+\.' | awk '{print $2}' | cut -d\? -f1 | sort | uniq
}

export NVM_DIR="/Users/marc.droz/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

alias luamake=/tmp/lua-language-server/3rd/luamake/luamake
