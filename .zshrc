zstyle    ':z4h:'                                        auto-update            no
zstyle    ':z4h:*'                                       channel                stable
zstyle    ':z4h:'                                        cd-key                 alt
zstyle    ':z4h:autosuggestions'                         forward-char           accept
zstyle    ':z4h:ssh:*'                                   ssh-command            command ssh
zstyle    ':z4h:ssh:*'                                   send-extra-files       '~/.zsh-aliases'
zstyle -e ':z4h:ssh:*'                                   retrieve-history       'reply=($ZDOTDIR/.zsh_history.${(%):-%m}:$z4h_ssh_host)'
zstyle    ':z4h:ssh:router'                              passthrough            yes
zstyle    ':fzf-tab:*'                                   continuous-trigger     tab
zstyle    ':zle:(up|down)-line-or-beginning-search'      leave-cursor           no

z4h install romkatv/archive || return

z4h init || return

if (( P9K_SSH )); then
    zstyle ':z4h' term-title-preexec '%* | %n@%m: ${1//\%/%%}'
    zstyle ':z4h' term-title-precmd  '%n@%m: %~'
else
    zstyle ':z4h' term-title-preexec '%* | ${1//\%/%%}'
    zstyle ':z4h' term-title-precmd  '%~'
fi

fpath+=($Z4H/romkatv/archive)
autoload -Uz archive lsarchive unarchive edit-command-line

my-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line -w
    else
        zle push-input -w
        zle clear-screen -w
    fi
}
zle -N my-ctrl-z
bindkey '^Z' my-ctrl-z

toggle-sudo() {
    [[ -z "$BUFFER" ]] && zle up-history -w
    if [[ "$BUFFER" != "sudo "* ]]; then
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR + 5 ))
    else
        BUFFER="${BUFFER#sudo }"
    fi
}
zle -N toggle-sudo
bindkey '^[s' toggle-sudo

zle -N edit-command-line
bindkey '^V^V' edit-command-line

bindkey '^H'      z4h-backward-kill-word
bindkey '^[[1;7C' z4h-forward-zword
bindkey '^[[1;7D' z4h-backward-zword
bindkey '^[[3;7~' z4h-kill-zword
bindkey '^[^H'    z4h-backward-kill-zword

command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

setopt GLOB_DOTS

z4h source -c /etc/bash_completion.d/azure-cli
z4h source -c /usr/share/LS_COLORS/dircolors.sh
z4h source -c ~/.zsh-aliases
z4h source -c ~/.zshrc-private

[ -f ~/.dotfiles/z4h.patch ] && patch -Np1 -i ~/.dotfiles/z4h.patch -r /dev/null -d $Z4H/zsh4humans/ > /dev/null

return 0
