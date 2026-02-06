
___x_cmd_co_hotkey_bind___zsh() {
    if [ -n "$BUFFER" ]; then
        local _oldbuffer="${PREBUFFER}${BUFFER}"
        BUFFER=""
        zle -I && zle redisplay
        ___x_cmd co --hotkey --exec "$_oldbuffer"
        zle end-of-line
    else
        co:info Null
    fi
    ___x_cmd_co_hotkey___reset_prompt_unit
}

___x_cmd_co_hotkey_bind(){
    local hotkey="$1"
    co:info "Binding hotkey -> $hotkey"
    zle -N ___x_cmd_co_hotkey_bind___zsh
    bindkey "$hotkey" "___x_cmd_co_hotkey_bind___zsh"
}
