[[ -o interactive ]] || return

opt_source() { [[ -r "$1" ]] && source "$1"; }

figlet -w 100 -f slant "Swervice Twade!"

HISTSIZE=1000
SAVEHIST=2000
HISTFILE="$HOME/.zhistory"

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt PROMPT_SUBST
unsetopt MENU_COMPLETE
setopt AUTO_MENU
setopt AUTO_LIST

export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export BROWSER=chrome
export PHP_VERSION=8.1

fpath=(~/.zfunc $fpath)
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz zsh_prompt && zsh_prompt

autoload -Uz delegate_to_bash

alias ls='ls -G'
alias m1='cd ~/workspace/partsledger-middleware '
alias m2='cd ~/workspace/parts'
alias m3='cd ~/workspace/sl_app'
alias m4='cd ~/workspace/partsledger-scripts/DataQuality'
alias m5='cd ~/workspace/SNaaP/'
alias m6='cd ~/workspace/ai-scheduler && nvm use 22'

opt_source "$HOME/.zsh_aliases"
opt_source "$HOME/.bash_aliases"
opt_source "$NVM_DIR/nvm.sh"
opt_source "$NVM_DIR/bash_completion"
opt_source "$HOME/.secrets"

typeset -U path PATH
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]] && path=("/opt/homebrew/opt/gnu-sed/libexec/gnubin" $path)
[[ -d "/snap/bin" ]] && path=("/snap/bin" $path)
[[ -d "/opt/homebrew/bin" ]] && path=("/opt/homebrew/bin" $path)
[[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)
[[ -d "$PYENV_ROOT/shims" ]] && path=("$PYENV_ROOT/shims" $path)
export PATH

awsp() { delegate_to_bash "$HOME/bin/awsp" awsp AWS_PROFILE AWS_REGION AWS_DEFAULT_REGION -- "$@"; }
aws-ssm() { delegate_to_bash "$HOME/bin/aws-ssm" aws-ssm -- "$@"; }
aws-ec2-ls() { delegate_to_bash "$HOME/bin/aws-ec2-ls.sh" aws-ec2-ls -- "$@"; }

complete -C aws_completer aws

