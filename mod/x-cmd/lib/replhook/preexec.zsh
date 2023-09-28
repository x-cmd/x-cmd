# shellcheck shell=zsh

autoload -Uz add-zsh-hook
# normally, zsh has precmd and preexe

___x_cmd_replhook_precmd_add(){
    add-zsh-hook precmd "$1"
}

___x_cmd_replhook_preexec_add(){
    add-zsh-hook preexec "$1"
}

___x_cmd_replhook_precmd_rm(){
    add-zsh-hook -D precmd "$1"
}

___x_cmd_replhook_preexec_rm(){
    add-zsh-hook -D preexec "$1"
}
