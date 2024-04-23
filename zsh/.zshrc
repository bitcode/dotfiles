# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

export ZSH="/home/bit/.oh-my-zsh"
ZSH_THEME=powerlevel10k/powerlevel10k
# Uncomment the following line to display red dots whilst waiting for completion.
 COMPLETION_WAITING_DOTS="true"
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
)
#ZSH_TMUX_AUTOSTART='true'
#source $ZSH/oh-my-zsh.sh
ZSH_DISABLE_COMPFIX='true'
export ZSH_CUSTOM=$HOME/.oh-my-zsh/custom/plugins
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
export VISUAL=nvim
export EDITOR=nvim
export PATH="$HOME/.cargo/bin:$PATH"
export AUTOSWITCH_VIRTUAL_ENV_DIR=".virtualenv"
export PATH=$PATH:$HOME/go/bin
export PYTHONPATH=/usr/bin/python3
export XDG_CONFIG_HOME=$HOME/.config/
export BROWSER=/usr/bin/firefox # for web-browser
export TERM=xterm-256color
export PATH=$PATH:/opt/gradle/gradle-8.7/bin
source $HOME/tmux_autostart.sh
source $HOME/.cargo/bin
source $HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source $HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
#source $HOME/.envs.sh
export PATH=$PATH:/usr/local/bin/geckodriver
export PATH=$PATH:/usr/local/bin/alacritty
export TERM=alacritty
export LD_LIBRARY_PATH="/home/bit/.pyenv/versions/3.12.2/lib/:$LD_LIBRARY_PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export MAX_PATH="/home/bit/.modular/pkg/packages.modular.com_max/bin/"
export PATH="/home/bit/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
export MODULAR_HOME="/home/bit/.modular"
#export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

# Manage History
HISTFILE=~/.zsh_history

HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY

#------- Aliases ---------

alias multi_clip='~/dotfiles/scripts/multi_clip_xclip.sh'
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
set -o vi
alias py='python3'
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias lg='lazygit'
alias python='/usr/bin/python3'
alias askollama='ask --model=orca2'

#------- Vim Mode Cursor Styling ---

# Load zsh-vi-mode
source $ZSH_CUSTOM/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Enable cursor style feature
ZVM_CURSOR_STYLE_ENABLED=true

# Set cursor styles for different modes
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
ZVM_REPLACE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK

# Optionally, customize colors and blinking
zvm_config() {
  # Use the 'zvm_cursor_style' function to set custom cursor styles
  local ncur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)
  local icur=$(zvm_cursor_style $ZVM_INSERT_MODE_CURSOR)

  ZVM_INSERT_MODE_CURSOR=$icur'\e]12;red\a'
  ZVM_NORMAL_MODE_CURSOR=$ncur'\e]12;#008800\a'
}

# Call the configuration function
zvm_config

# zoxide

# Load and initialize compinit
autoload -Uz compinit
compinit

# Initialize zoxide
eval "$(zoxide init --cmd cd zsh)"

# Optionally, clear and reinitialize completion cache if needed
# rm ~/.zcompdump*; COMPLETION_WAITING_DOTS

#------SiteMap Script -----

sitemap(){
lynx -dump "http://hackerone.com" | sed -n '/^References$/,$p' | grep -E '[[:digit:]]+\.' | awk '{print $2}' | cut -d\? -f1 | sort | uniq
}

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Bug Bounty tools
#

#----- AWS -------

s3ls(){
aws s3 ls s3://$1
}

s3cp(){
aws s3 cp $2 s3://$1 
}

#---- Content discovery ----
thewadl(){ #this grabs endpoints from a application.wadl and puts them in yahooapi.txt
curl -s $1 | grep path | sed -n "s/.*resource path=\"\(.*\)\".*/\1/p" | tee -a ~/tools/dirsearch/db/yahooapi.txt
}

#----- recon -----
crtndstry(){
./tools/crtndstry/crtndstry $1
}

am(){ #runs amass passively and saves to json
amass enum --passive -d $1 -json $1.json
jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

certprobe(){ #runs httprobe on all the hosts from certspotter
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt
}

#mscan(){ #runs masscan
#sudo masscan -p4443,2075,2076,6443,3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,744$}
#}

certspotter(){ 
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1
} #h/t Michiel Prins

crtsh(){
curl -s https://crt.sh/?Identity=%.$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF'
}

certnmap(){
curl https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1  | nmap -T5 -Pn -sS -i - -$
} #h/t Jobert Abma

ipinfo(){
curl http://ipinfo.io/$1
}


#------ Tools ------
dirsearch(){ runs dirsearch and takes host and extension as arguments
python3 ~/tools/dirsearch/dirsearch.py -u $1 -e $2 -t 50 -b 
}

sqlmap(){
python ~/tools/sqlmap*/sqlmap.py -u $1 
}

ncx(){
nc -l -n -vv -p $1 -k
}

crtshdirsearch(){ #gets all domains from crtsh, runs httprobe and then dir bruteforcers
curl -s https://crt.sh/?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe -c 50 | grep https | xargs -n1 -I{} python3 ~/tools/dirsearch/dirsearch.py -u {} -e $2 -t 50 -b 
}
eval "$(zellij setup --generate-auto-start zsh)"
