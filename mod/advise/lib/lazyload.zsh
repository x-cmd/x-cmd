# shellcheck shell=zsh

# Lazy loading of advise completion
#
# Bind Tab to a proxy widget. On the first Tab press, advise completion is
# loaded via `___x_cmd_advise___rcload`, then the original Tab binding is
# restored and executed, so the first press still completes as usual.

___x_cmd_advise___lazyload(){
    ___x_cmd_is_suitable_advise_repl || return 1
    [ -n "$ZSH_VERSION" ] || return 1

    local x_="$(bindkey '^I' 2>/dev/null)"

    # Already installed (e.g. the rc file got sourced twice) -- do not
    # recapture the binding, otherwise the proxy widget would call itself
    [ "$x_" = '"^I" ___x_cmd_advise_lazy_tab' ] && return 0

    # Remember the original Tab binding (defaults to expand-or-complete)
    ___X_CMD_ADVISE_ORIG_TAB_BINDING="${x_[(w)2]:-expand-or-complete}"

    ___x_cmd_advise_lazy_tab(){
        # Recursion guard: never call the proxy widget from itself
        if [ -n "$___X_CMD_ADVISE_LAZY_TAB_RUNNING" ]; then
            zle expand-or-complete
            return
        fi
        ___X_CMD_ADVISE_LAZY_TAB_RUNNING=1

        local orig="${___X_CMD_ADVISE_ORIG_TAB_BINDING:-expand-or-complete}"
        [ "$orig" = "___x_cmd_advise_lazy_tab" ] && orig=expand-or-complete

        ___x_cmd_advise___rcload
        # Restore the original binding only if rcload hasn't changed it
        if [ "$(bindkey '^I' 2>/dev/null)" = '"^I" ___x_cmd_advise_lazy_tab' ]; then
            bindkey '^I' "$orig"
        fi

        zle "$orig"
        local rc=$?
        unset ___X_CMD_ADVISE_LAZY_TAB_RUNNING
        return "$rc"
    }

    zle -N ___x_cmd_advise_lazy_tab
    bindkey '^I' ___x_cmd_advise_lazy_tab
}
