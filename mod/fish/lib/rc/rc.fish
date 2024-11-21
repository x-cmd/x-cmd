
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
    if [ "$OS" != "Windows_NT" ]
        bash "$HOME/.x-cmd.root/bin/___x_cmdexe_exp" $argv
    else
        "$HOME/.x-cmd.root/bin/___x_cmdexe_exp.bat" $argv
    end

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
            else if [ -d "$argv[1]" ]
                cd "$argv[1]"
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
    [ -f "$HOME/.x-cmd.root/boot/alias/xwt.disable"     ]  ||  alias xwt="___x_cmd webtop"

    [ -f "$HOME/.x-cmd.root/boot/alias/co.disable"      ]  ||  begin
        alias ,="___x_cmd fish --sysco"
        alias "，"="___x_cmd fish --sysco"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/coco.disable"    ]  ||  begin
        alias ,,="___x_cmd fish --syscoco"
        alias "，，"="___x_cmd fish --syscoco"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/chat.disable"    ]  ||  begin
        if [ ! -f "$HOME/.x-cmd.root/local/cache/chat/bootcode.fish" ]
            mkdir -p "$HOME/.x-cmd.root/local/cache/chat"
            ___x_cmd chat --aliasinit --code > "$HOME/.x-cmd.root/local/cache/chat/bootcode.fish"
        end
        source "$HOME/.x-cmd.root/local/cache/chat/bootcode.fish"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/writer.disable"  ]  ||  begin
        if [ ! -f "$HOME/.x-cmd.root/local/cache/writer/bootcode.fish" ]
            mkdir -p "$HOME/.x-cmd.root/local/cache/writer"
            ___x_cmd writer --aliasinit --fishcode > "$HOME/.x-cmd.root/local/cache/writer/bootcode.fish"
        end
        source "$HOME/.x-cmd.root/local/cache/writer/bootcode.fish"
    end

    if [ "$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL" = '1' ]
        if [ ! -f "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish" ]
            mkdir -p "$HOME/.x-cmd.root/local/cache/advise/bootcode"
            ___x_cmd advise complete fish code > "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish"
        end
        source "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish"
    end
end

function ___x_cmd___rcfish_addp_prepend
    if ! contains -- "$argv[1]" $PATH
        set -g PATH "$argv[1]" "$PATH"
    end
end

function ___x_cmd___rcfish_addp_append
    if ! contains -- "$argv[1]" $PATH
        set -g PATH "$PATH" "$argv[1]"
    end
end

function ___x_cmd___rcfish_addpifh
    if command -v "$argv[1]" >/dev/null 2>&1
        ___x_cmd___rcfish_addp_prepend "$argv[2]"
    end
end

function ___x_cmd___rcfish_addpifd
    if [ -d "$argv[1]" ]
        ___x_cmd___rcfish_addp_prepend "$argv[1]"
    end
end

function ___x_cmd___rcfish_addpython
    ___x_cmd___rcfish_addpifh python "$HOME/.local/bin"

    set singleton_fp "$HOME/.x-cmd.root/local/data/pkg/sphere/X/.x-cmd/singleton/python"
    if [ -f "$singleton_fp" ]
        set tgtdir "$HOME/.x-cmd.root/local/data/pkg/sphere/X/"(cat $singleton_fp)
        if [ "$OS" = "Windows_NT" ]
            set binpath "$tgtdir/Scripts"
        else
            set binpath "$tgtdir/bin"
        end
        ___x_cmd___rcfish_addpifd "$binpath"
    end
end


if [ -f "$HOME/.x-cmd.root/boot/pixi" ]
    ___x_cmd___rcfish_addp_append   "$HOME/.pixi/bin"
end

___x_cmd___rcfish_addp_prepend      "$HOME/.x-cmd.root/bin"
___x_cmd___rcfish_addp_prepend      "$HOME/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin"

___x_cmd___rcfish_addpifd           "$HOME/.cargo/bin"
___x_cmd___rcfish_addpifh  go       "$HOME/go/bin"
___x_cmd___rcfish_addpifh  deno     "$HOME/.deno/bin"
___x_cmd___rcfish_addpifh  bun      "$HOME/.bun/bin"
___x_cmd___rcfish_addpifh  npm      "$HOME/.npm/bin"
___x_cmd___rcfish_addpython
