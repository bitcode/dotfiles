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
  kubectl
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
#------- Aliases ---------

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

#------- swap caps with escape ---

# setxkbmap -option caps:swapescape

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

