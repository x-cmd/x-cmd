
___x_cmd_hotkey_co_bind___bash() {
    if [ -n "$READLINE_LINE" ]; then
        ___x_cmd hotkey co --exec "$READLINE_LINE"
        READLINE_LINE=""
        READLINE_POINT="${#READLINE_LINE}"
    else
        hotkey:info "Null"
    fi

    ___x_cmd_hotkey_co___reset_prompt_unit
    stty -raw 2>/dev/null
    stty -istrip 2>/dev/null
    stty echo 2>/dev/null
}

___x_cmd_hotkey_co_bind(){
    local hotkey="$1"
    bind -x '"'"$hotkey"'":___x_cmd_hotkey_co_bind___bash'
}
