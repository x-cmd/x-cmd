# shellcheck shell=bash disable=SC2329

# Lazy loading of advise completion
#
# Proxy Tab through an auxiliary key (C-x C-z). The Tab macro first invokes
# the loader, then presses Tab again; because readline expands macros
# keystroke by keystroke, the second ^I resolves to the binding restored by
# the loader -- so the first Tab press loads advise completion and completes
# in one go. (Same trick fzf uses for its key bindings.)

# Set x_ to the current Tab binding from `bind $1` output
# (-s: macro, -p: readline function); empty x_ means Tab is not bound
___x_cmd_advise___orig_tab_binding_(){
    x_=
    while IFS= read -r x_; do
        case "$x_" in
            '"\C-i":'*) return 0 ;;
        esac
    done < <(bind "$1" 2>/dev/null)
    x_=
    return 1
}

___x_cmd_advise___lazyload(){
    ___x_cmd_is_suitable_advise_repl || return 1
    [ -n "$BASH_VERSION" ] || return 1
    [ -z "$___X_CMD_ADVISE_SHELL_BASH_LT_4_2" ] || return 1

    # Remember the original Tab binding before shadowing it -- a macro
    # (bind -s) takes precedence over a readline function (bind -p);
    # empty means Tab was not bound. Pure builtin, no external commands.
    local x_=
    ___x_cmd_advise___orig_tab_binding_ -s || ___x_cmd_advise___orig_tab_binding_ -p
    # Already installed (e.g. the rc file got sourced twice) -- do not
    # recapture the binding, otherwise Tab would restore to our own macro
    # and recurse forever
    [ "$x_" = '"\C-i": "\C-x\C-z\C-i"' ] && return 0
    ___X_CMD_ADVISE_ORIG_TAB_BINDING="$x_"

    ___x_cmd_advise_lazy_tab(){
        # Recursion guard: never run the loader from itself
        [ -n "$___X_CMD_ADVISE_LAZY_TAB_RUNNING" ] && return
        ___X_CMD_ADVISE_LAZY_TAB_RUNNING=1

        ___x_cmd_advise___rcload
        case "$___X_CMD_ADVISE_ORIG_TAB_BINDING" in
            # Never restore to our own macro -- that would recurse forever
            '"\C-i": "\C-x\C-z\C-i"')
                bind '"\C-i": complete' ;;
            "")
                bind -r '\C-i' ;;
            *)
                bind "$___X_CMD_ADVISE_ORIG_TAB_BINDING" ;;
        esac
        bind -r '\C-x\C-z'

        unset ___X_CMD_ADVISE_LAZY_TAB_RUNNING
    }

    bind -x '"\C-x\C-z": ___x_cmd_advise_lazy_tab'
    bind '"\C-i": "\C-x\C-z\C-i"'
}
