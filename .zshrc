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


typeset -U path PATH
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]] && path=("/opt/homebrew/opt/gnu-sed/libexec/gnubin" $path)
[[ -d "/snap/bin" ]] && path=("/snap/bin" $path)
[[ -d "/opt/homebrew/bin" ]] && path=("/opt/homebrew/bin" $path)
export PATH

export BROWSER=chrome

alias m1='cd ~/workspace/partsledger-middleware'
alias m2='cd ~/workspace/parts'
alias m3='cd ~/workspace/sl_app'
alias m4='cd ~/workspace/partsledger-scripts/DataQuality'
alias m5='cd ~/workspace/SNaaP/'
alias m6='cd ~/workspace/ai-scheduler'

# Delegate bash scripts to bash interpreter, capturing env var changes
[[ -f "$HOME/bin/delegate_to_bash.zsh" ]] && source "$HOME/bin/delegate_to_bash.zsh"

if [[ -f "$HOME/bin/awsp" ]]; then
    awsp() { delegate_to_bash "$HOME/bin/awsp" awsp AWS_PROFILE AWS_REGION AWS_DEFAULT_REGION -- "$@"; }
fi
if [[ -f "$HOME/bin/aws-ssm" ]]; then
    aws-ssm() { delegate_to_bash "$HOME/bin/aws-ssm" aws-ssm -- "$@"; }
fi
if [[ -f "$HOME/bin/aws-ec2-ls.sh" ]]; then
    aws-ec2-ls() { delegate_to_bash "$HOME/bin/aws-ec2-ls.sh" aws-ec2-ls -- "$@"; }
fi

if command -v aws_completer >/dev/null 2>&1; then
  autoload -Uz bashcompinit
  bashcompinit
  complete -C "$(command -v aws_completer)" aws
fi

export PHP_VERSION=8.1
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"
