eval "$(starship init zsh)"
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000              
SAVEHIST=10000              
HISTCONTROL=ignoredups      
HISTIGNORE="ls:cd:pwd" 

setopt append_history      
setopt share_history

setopt inc_append_history

# Exa
alias ls='eza --icons --group-directories-first'
alias bat="bat --plain"
# alias ssh="export TERM=xterm-256color && ssh"

autoload -U add-zsh-hook

function add_blank_line_after_command() {
    echo ""
}

add-zsh-hook precmd add_blank_line_after_command


export PATH=/opt/cuda/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH


# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/haidhi/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<
autoload -U compinit; compinit

# Podman
podman-ps-pretty() {
  printf "\033[1m%-14s %-24s %-18s %s\033[0m\n" \
    "CONTAINER ID" "IMAGE" "STATUS" "NAME"

  podman ps -a --format "{{.ID}}|{{.Image}}|{{.Status}}|{{.Names}}" |
  while IFS='|' read -r id image status name; do
    short_id=${id:0:12}

    if [[ "$status" == Up* ]]; then
      status_color="\033[32m"   # green
    elif [[ "$status" == Exited* ]]; then
      status_color="\033[31m"   # red
    else
      status_color="\033[33m"   # yellow
    fi

    printf "%-14s %-24s ${status_color}%-18s\033[0m %s\n" \
      "$short_id" "$image" "$status" "$name"
  done
}


# minikube
alias kubectl="minikube kubectl --"
