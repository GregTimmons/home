[[ -o interactive ]] || return

if command -v figlet >/dev/null 2>&1; then
  figlet -w 100 -f slant "Swervice Twade!"
fi

HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zhistory"
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

if [[ -x /usr/bin/lesspipe ]]; then
  eval "$(SHELL=/bin/sh /usr/bin/lesspipe)"
fi

export GIT_PS1_SHOWDIRTYSTATE=1

autoload -Uz colors vcs_info
colors
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' (%b%u%c)'
precmd() { vcs_info; }
PROMPT='%F{green}%n@%m%f %F{cyan}${AWS_PROFILE:-no-profile}%f %F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f $ '

if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
elif ls -G -d . >/dev/null 2>&1; then
  alias ls='ls -G'
fi

if printf 'x\n' | grep --color=auto x >/dev/null 2>&1; then
  alias grep='grep --color=auto'
fi
alias fgrep='grep -F'
alias egrep='grep -E'

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alert() {
  local last_status=$?
  local icon="terminal"
  [[ $last_status -ne 0 ]] && icon="error"
  local last_cmd
  last_cmd="$(fc -ln -1 | sed -E 's/[;&|][[:space:]]*alert$//')"
  if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Shell Alert" -message "$last_cmd"
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send --urgency=low -i "$icon" "$last_cmd"
  fi
}

[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

autoload -Uz compinit
compinit

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  autoload -Uz bashcompinit
  bashcompinit
  source "$NVM_DIR/bash_completion"
fi

if [[ "$(uname -s)" == "Linux" ]]; then
  if ! pgrep -x dockerd >/dev/null 2>&1; then
    echo "Starting the docker daemon..."
    sudo dockerd >/dev/null 2>&1 &
    disown
  else
    echo "Docker appears to be running..."
  fi
fi

typeset -U path PATH
[[ -d /usr/local/go/bin ]] && path=(/usr/local/go/bin $path)
[[ -d "$HOME/.meteor" ]] && path=("$HOME/.meteor" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d /snap/bin ]] && path+=("/snap/bin")
export PATH

export BROWSER=chrome

if [[ "$(uname -s)" == "Linux" ]]; then
  if screen -ls 2>&1 | grep -q "Cannot make"; then
    echo "Creating /run/screen directory..."
    sudo mkdir -p /run/screen && sudo chmod 777 /run/screen
  else
    echo "Screen appears to be ok..."
  fi
fi

alias m1='cd /workspace/partsledger-middleware'
alias m2='cd /workspace/parts'
alias m3='cd /workspace/sl_app'
alias m4='cd /workspace/partsledger-scripts/DataQuality'
alias m5='cd /workspace/SNaaP/'
alias m6='cd /workspace/scheduler'
if command -v docker-compose >/dev/null 2>&1; then
  alias dc='docker-compose'
else
  alias dc='docker compose'
fi
alias kc='kubectl'
alias lredis='kubectl exec --tty -i redis-client --namespace backend -- bash -c "REDISCLI_AUTH=\"redis\" redis-cli -h redis-master"'

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

[[ -f "$HOME/bin/awsp" ]] && source "$HOME/bin/awsp"
[[ -f "$HOME/bin/aws-ssm" ]] && source "$HOME/bin/aws-ssm"
[[ -f "$HOME/bin/aws-ec2-ls.sh" ]] && source "$HOME/bin/aws-ec2-ls.sh"
if command -v aws_completer >/dev/null 2>&1; then
  autoload -Uz bashcompinit
  bashcompinit
  complete -C "$(command -v aws_completer)" aws
fi

export PATH="/opt/homebrew/bin:$PATH"
export PHP_VERSION=8.1
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
