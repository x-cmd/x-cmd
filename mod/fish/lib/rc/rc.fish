
set -g ___X_CMD_CD_RELM_0 $PWD

function ___x_cmd___rcfish_oldpwd
    set -l dirc (count $dirnext)
    if test $dirc -gt 0
        echo $dirnext[-1]
        return
    end

    set -l dirc (count $dirprev)
    if test $dirc -gt 0
        echo $dirprev[-1]
    end
end

function x
    switch $argv[1]
        case 'cd'
            set argv $argv[2..-1]
            ___x_cmd_cd $argv
            return
    end
    ___x_cmd $argv
end

function ___x_cmd
    set -x ___X_CMD_CD_RELM_0               "$___X_CMD_CD_RELM_0"
    set -x ___X_CMD_REAL_CALLER_SHELL       "$___X_CMD_REAL_CALLER_SHELL"
    set -x ___X_CMD_RUNMODE                 "$___X_CMD_RUNMODE"
    set -x ___X_CMD_XBINEXP_FP              "$HOME/.x-cmd.root/local/data/xbinexp/fish/$fish_pid"_(random)
    set -x ___X_CMD_XBINEXP_INITENV_OLDPWD  "$OLDPWD"
    # mkdir -p $___X_CMD_XBINEXP_FP

    bash "$HOME/.x-cmd.root/bin/___x_cmdexe_exp" $argv

    set exit_status $status

    set -l tmpvar
    set tmpvar "$___X_CMD_CD_RELM_0";           set -e ___X_CMD_CD_RELM_0;              set -g ___X_CMD_CD_RELM_0           "$tmpvar"
    set tmpvar "$___X_CMD_REAL_CALLER_SHELL";   set -e ___X_CMD_REAL_CALLER_SHELL;      set -g ___X_CMD_REAL_CALLER_SHELL "$tmpvar"
    set -e ___X_CMD_XBINEXP_INITENV_OLDPWD

    if [ ! -d "$___X_CMD_XBINEXP_FP" ]
        return $exit_status
    end

    set -g ___X_CMD_XBINEXP_EVAL ""
    for file in $___X_CMD_XBINEXP_FP/*
        set varname (string replace -r '^.*/[^_]+_' '' "$file")
        if [ $varname = PWD ]
            set -gx OLDPWD "$PWD"
            cd (cat $file)
        else
            set -g "$varname" (cat $file)
        end
    end

    if string match -q "*xbinexp/fish*" "$___X_CMD_XBINEXP_FP"
        rm -rf "$___X_CMD_XBINEXP_FP"
    end

    if [ -n "$___X_CMD_XBINEXP_EVAL" ]
        set -l data "$___X_CMD_XBINEXP_EVAL"
        set -e ___X_CMD_XBINEXP_EVAL
        printf "%s\n" "===================" >&2
        printf ">>> %s\n\n" "$data" >&2
        printf "%s\n" "-------------------" >&2
        eval "$data"
        printf "\n%s\n" "===================" >&2
    end

    set -e ___X_CMD_XBINEXP_FP
    return $exit_status
end

function ___x_cmd_cd
    set -l -a last_dirnext $dirnext
    set -l -a last_dirprev $dirprev
    set -l -a last_fish_cd_direction $__fish_cd_direction

    set -l original_dir "$PWD"
    if test "$argv[1]" = "-"
        cd - || return $status
        ___x_cmd cd --history top "$PWD"
        set argv $argv[2..-1]
    else
        switch $argv[1]
            case '-b' '-f'
                ___x_cmd cd $argv[1] $argv[2] || return $status
                set argv $argv[3..-1]

            case '-*'
                ___x_cmd cd $argv
                return $status

            case '*'
                ___x_cmd cd $argv[1] || return $status
                set argv $argv[2..-1]
        end
    end

    if test (count $argv) -gt 0
        switch $argv[1]
            case '-' '--'
                set argv $argv[2..-1]
        end
        test (count $argv) -gt 0 || return 0
        printf "%s\n" "- I|cd: Change the directory [$PWD] to execute -> '$argv'" >&2
        $argv
        set -l exit_status $status
        ___x_cmd cd $original_dir

        set -e dirprev; set -g -a dirprev $last_dirprev
        set -e dirnext; set -g -a dirnext $last_dirnext
        set -e __fish_cd_direction; set -g __fish_cd_direction $last_fish_cd_direction
        return $exit_status
    end
end

# TODO: in the future, adding the advise

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
set -g ___X_CMD_RUNMODE 0
if status is-interactive
    set -g ___X_CMD_REAL_CALLER_SHELL fish
    set -g ___X_CMD_RUNMODE 9
    # setenv ___X_CMD_CO_EXEC_SHELL=fish

    [ -n "$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL" ] || begin
        set -g ___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL 1
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/co.disable"      ]  ||  begin
        alias ,="___x_cmd fish --sysco"
        alias "，"="___x_cmd fish --sysco"
    end

    [ -f "$HOME/.x-cmd.root/boot/alias/coco.disable"    ]  ||  begin
        alias ,,="___x_cmd fish --syscoco"
        alias "，，"="___x_cmd fish --syscoco"
    end

    if [ -f "$HOME/.x-cmd.root/local/cache/shortcut/compile/shortcut.fish" ]
        source "$HOME/.x-cmd.root/local/cache/shortcut/compile/shortcut.fish"
    end

    if [ "$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL" = '1' ]
        if [ ! -f "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish" ]
            mkdir -p "$HOME/.x-cmd.root/local/cache/advise/bootcode"
            ___x_cmd advise complete fish code > "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish"
        end
        source "$HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.fish"

        if [ -f "$HOME/.x-cmd.root/local/cache/advise/addon/complete.fish" ]
            source "$HOME/.x-cmd.root/local/cache/advise/addon/complete.fish"
        end
    end

    if [ -f "$HOME/.x-cmd.root/local/cfg/theme/use/fish/default.fish" ]
        source "$HOME/.x-cmd.root/local/cfg/theme/use/fish/default.fish"
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
