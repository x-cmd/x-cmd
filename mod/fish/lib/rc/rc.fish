
# add path to .x-cmd.root/bin and .x-cmd.root/global/data/bin/l/j/h

if ! contains -- $HOME/.x-cmd.root/bin $PATH
    set -g PATH $HOME/.x-cmd.root/bin $PATH
end

if ! contains -- $HOME/.x-cmd.root/global/data/bin/l/j/h/bin $path
    set -g PATH $HOME/.x-cmd.root/global/data/bin/l/j/h/bin $PATH
end

function x
    ___x_cmd $argv
end

function ___x_cmd
    setenv ___X_CMD_XBINEXP_FP $HOME/.x-cmd.root/local/data/xbinexp/fish/$status/$(random)
    mkdir -p $___X_CMD_XBINEXP_FP
    bash "$HOME/.x-cmd.root/bin/xbinexp" $argv

    if [ -f "$___X_CMD_XBINEXP_FP/PWD" ]
        cd "$(cat $___X_CMD_XBINEXP_FP/PWD)"
        rm "$___X_CMD_XBINEXP_FP/PWD"
    end

    if [ -f "$___X_CMD_XBINEXP_FP/PATH" ]
        setenv PATH "$(cat $___X_CMD_XBINEXP_FP/PATH)"
        rm "$___X_CMD_XBINEXP_FP/PATH"
    end

    for file in $___X_CMD_XBINEXP_FP/*
        set rmlist $rmlist $file

        set varname (string replace -r '^[^_]+_' '' (basename $file))
        # set -g "$varname" "$(cat $file)"
        setenv "$varname" "$(cat $file)"
    end

    if [ (count $rmlist) -gt 0 ]
        rm -f $rmlist
    end

    if [ -n "$___X_CMD_XBINEXP_EVAL" ]
        set data "$___X_CMD_XBINEXP_EVAL"
        set -u ___X_CMD_XBINEXP_EVAL ""
        printf "%s\n" "===================" >&2
        printf ">>> %s\n\n" "$data" >&2
        printf "%s\n" "-------------------" >&2
        eval "$data"
        printf "\n%s\n" "===================" >&2
    end
end

# TODO: in the future, adding the advise

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
if status is-interactive
    setenv ___X_CMD_IS_INTERACTIVE_FORCE 1
    # setenv ___X_CMD_CO_EXEC_SHELL=fish

    eval "$("$HOME/.x-cmd.root/bin/xbin" chat --aliasinit --code)"

    # chat, writer, w
    # eval "$("$HOME/.x-cmd.root/bin/xbin" aliasinit --code)"

    alias xw='x ws'
    alias c='x cd'
    alias xg='x git'
    # alias xd='x docker'

    alias ,="x fish --sysco"
end
setenv ___X_CMD_THEME_RELOAD_DISABLE 1

