case $- in
    *i*) ;;
      *) return;;
esac
figlet -w 100 -f slant "Swervice Twade!"
shopt -s histappend
shopt -s checkwinsize
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
export GIT_PS1_SHOWDIRTYSTATE=1
_G="\[$(tput setaf 2)\]"
_B="\[$(tput setaf 4)\]"
_Y="\[$(tput setaf 3)\]"
_C="\[$(tput setaf 6)\]"
_EC="\[$(tput setaf 7)\]"
PS1="${_G}\u@\h${_EC}"
PS1="${PS1} ${_C}\${AWS_PROFILE:-no-profile}${_EC}"
PS1="${PS1} ${_B}\w${_EC}"
PS1="${PS1}${_Y}\$(__git_ps1)${_EC}$ "
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# -----------------
# Init Docker
# -----------------
RUNNING=$(ps aux | grep dockerd | grep -v grep)
if [ -z "$RUNNING" ]; then
    echo "Starting the docker daemon..."
    sudo dockerd > /dev/null 2>&1 &
    disown
else
    echo "Docker appears to be running..."
fi

# -------------------
# Add custom Alias scripts to path
#------------------
export PATH=/usr/local/go/bin:${PATH}
export PATH=/home/ubuntu/.meteor:${PATH}
export PATH="~/bin:${PATH}";
#-------------
# Set browser for travis command
#-------------
export BROWSER=chrome
# ------------------
#  Init Screen
# -----------------
if screen -ls | grep -q "Cannot make"; then
        echo "Creating /run/screen directory...";
        sudo mkdir -p /run/screen && sudo chmod 777 /run/screen
else
        echo "Screen appears to be ok...";
fi
alias m1="cd /workspace/partsledger-middleware"
alias m2="cd /workspace/parts"
alias m3="cd /workspace/sl_app"
alias m4="cd /workspace/partsledger-scripts/DataQuality"



export PATH=$PATH:/snap/bin
export PATH=/home/gbtimmon/.meteor:$PATH
. "$HOME/.cargo/env"

alias kc=kubectl

# -----------------
# AWS Stuff
# -----------------
. ~/bin/awsp
. ~/bin/aws-ec2-ls.sh
complete -C '/usr/local/bin/aws_completer' aws

