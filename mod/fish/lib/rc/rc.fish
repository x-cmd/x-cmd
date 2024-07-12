
function ___x_cmd___rcfish_addp
    if ! contains -- "$argv[1]" "$PATH"
        set -g PATH "$argv[1]" "$PATH"
    end
end

function ___x_cmd___rcfish_addpifh
    if command -v "$argv[1]" >/dev/null 2>&1
        ___x_cmd___rcfish_addp "$argv[2]"
    end
end

function ___x_cmd___rcfish_addpifd
    if [ -d "$argv[1]" ]
        ___x_cmd___rcfish_addp "$argv[1]"
    end
end

if [ -f "$HOME/.x-cmd.root/boot/pixi" ]
    set -g PATH "$PATH"             "$HOME/.pixi/bin"
end

___x_cmd___rcfish_addp              "$HOME/.x-cmd.root/bin"
___x_cmd___rcfish_addp              "$HOME/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin"

___x_cmd___rcfish_addpifd           "$HOME/.cargo/bin"
___x_cmd___rcfish_addpifh  go       "$HOME/go/bin"

___x_cmd___rcfish_addpifh  python   "$HOME/.local/bin"

___x_cmd___rcfish_addpifh  deno     "$HOME/.deno/bin"
___x_cmd___rcfish_addpifh  bun      "$HOME/.bun/bin"
___x_cmd___rcfish_addpifh  npm      "$HOME/.npm/bin"


set -g ___X_CMD_CD_RELM_0 $PWD

function x
    ___x_cmd $argv
end

function ___x_cmd
    set -x ___X_CMD_CD_RELM_0               "$___X_CMD_CD_RELM_0"
    set -x ___X_CMD_THEME_RELOAD_DISABLE    "$___X_CMD_THEME_RELOAD_DISABLE"
    set -x ___X_CMD_IS_INTERACTIVE_FORCE    "$___X_CMD_IS_INTERACTIVE_FORCE"
    set -x ___X_CMD_XBINEXP_FP              "$HOME/.x-cmd.root/local/data/xbinexp/fish/$fish_pid"_(random)
    set -x ___X_CMD_XBINEXP_INITENV_OLDPWD  "$OLDPWD"
    # mkdir -p $___X_CMD_XBINEXP_FP

    bash "$HOME/.x-cmd.root/bin/xbinexp" $argv
    set exit_status $status

    set -u ___X_CMD_CD_RELM_0               "$___X_CMD_CD_RELM_0"
    set -u ___X_CMD_THEME_RELOAD_DISABLE    "$___X_CMD_THEME_RELOAD_DISABLE"
    set -u ___X_CMD_XBINEXP_FP              "$___X_CMD_XBINEXP_FP"
    set -u ___X_CMD_XBINEXP_INITENV_OLDPWD  "$___X_CMD_XBINEXP_INITENV_OLDPWD"

    if [ ! -d "$___X_CMD_XBINEXP_FP" ]
        return $exit_status
    end

    set -g ___X_CMD_XBINEXP_EVAL ""
    for file in $___X_CMD_XBINEXP_FP/*
        set varname (string replace -r '^.*/[^_]+_' '' "$file")
        if [ $varname = PWD ]
            cd (cat $file)
        else
            set -g "$varname" (cat $file)
        end
    end

    if string match -q "*xbinexp/fish*" "$___X_CMD_XBINEXP_FP"
        rm -rf "$___X_CMD_XBINEXP_FP"
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

    return $exit_status
end

# TODO: in the future, adding the advise

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
if status is-interactive
    set -g ___X_CMD_THEME_RELOAD_DISABLE 1
    set -g ___X_CMD_IS_INTERACTIVE_FORCE 1
    # setenv ___X_CMD_CO_EXEC_SHELL=fish

    [ -f "$HOME/.x-cmd.root/boot/alias/c.disable"     ]   ||  begin
        function c
            if [ "$argv[1]" = "-" ]
                cd -
                return
            end
            ___x_cmd cd $argv
        end
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/xx.disable"      ]  ||  alias xx='___x_cmd xx'
    [ -f "$HOME/.x-cmd.root/boot/alias/xw.disable"      ]  ||  alias xw='___x_cmd ws'
    [ -f "$HOME/.x-cmd.root/boot/alias/xd.disable"      ]  ||  alias xd='___x_cmd docker'
    [ -f "$HOME/.x-cmd.root/boot/alias/xg.disable"      ]  ||  alias xg='___x_cmd git'
    [ -f "$HOME/.x-cmd.root/boot/alias/xp.disable"      ]  ||  alias xp="___x_cmd pwsh"

    [ -f "$HOME/.x-cmd.root/boot/alias/co.disable"      ]  ||  begin
        alias ,="___x_cmd fish --sysco"
        alias "，"="___x_cmd fish --sysco"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/coco.disable"    ]  ||  begin
        alias ,,="___x_cmd fish --syscoco"
        alias "，，"="___x_cmd fish --syscoco"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/chat.disable"    ]  ||  eval ("$HOME/.x-cmd.root/bin/xbin" chat --aliasinit --code)
    [ -f "$HOME/.x-cmd.root/boot/alias/writer.disable"  ]  ||  eval ("$HOME/.x-cmd.root/bin/xbin" writer --aliasinit --fishcode)

end
