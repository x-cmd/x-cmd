# shellcheck shell=bash disable=SC2184
___x_cmd_replhook_precmd_add(){
    precmd_functions+=( "$1" )
}

___x_cmd_replhook_preexec_add(){
    preexec_functions+=( "$1" )
}

___x_cmd_replhook_precmd_rm(){
    local i; for i in "${!precmd_functions[@]}"; do
        [[ "${precmd_functions[$i]}" != "$1" ]] || unset precmd_functions["$i"]
    done
}

___x_cmd_replhook_preexec_rm(){
    local i; for i in "${!preexec_functions[@]}"; do
        [[ "${preexec_functions[$i]}" != "$1" ]] || unset preexec_functions["$i"]
    done
}
