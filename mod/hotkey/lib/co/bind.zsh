
___x_cmd_hotkey_co_bind___zsh() {
    if [ -n "$BUFFER" ]; then
        local _oldbuffer="${PREBUFFER}${BUFFER}"
        BUFFER=""; LBUFFER=""; RBUFFER=""; POSTDISPLAY=""
        zle -I && zle redisplay
        ___x_cmd hotkey co --exec "$_oldbuffer"
        zle end-of-line
    else
        hotkey:info Null
    fi
    ___x_cmd_hotkey_co___reset_prompt_unit
}

___x_cmd_hotkey_co_bind(){
    local hotkey="$1"
    zle -N ___x_cmd_hotkey_co_bind___zsh
    bindkey "$hotkey" "___x_cmd_hotkey_co_bind___zsh"
}
