# add path to .x-cmd.root/bin and .x-cmd.root/global/data/bin/l/j/h

if ( -f "$HOME/.x-cmd.root/boot/pixi" ) then
    if ( "$PATH" !~ *$HOME/.pixi/bin* )  setenv PATH "$PATH":$HOME/.pixi/bin
endif

# TODO: improve this ...
if ( "$PATH" !~ *$HOME/.x-cmd.root/bin* ) then
    setenv PATH $HOME/.x-cmd.root/bin:$HOME/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin:"$PATH"
endif

if ( -d "$HOME/.cargo/bin" ) then
    if ( "$PATH" !~ *$HOME/.cargo/bin* )  setenv PATH $HOME/.cargo/bin:"$PATH"
endif

foreach prog ( go deno bun npm python )
    which $prog > /dev/null
    if ( $? == 0 ) then
        switch ($prog)
            case go:
                if ( "$PATH" !~ *$HOME/go/bin* )        setenv PATH $HOME/go/bin:"$PATH"
                breaksw
            case deno:
                if ( "$PATH" !~ *$HOME/.deno/bin* )     setenv PATH $HOME/.deno/bin:"$PATH"
                breaksw
            case bun:
                if ( "$PATH" !~ *$HOME/.bun/bin* )      setenv PATH $HOME/.bun/bin:"$PATH"
                breaksw
            case npm:
                if ( "$PATH" !~ *$HOME/.npm/bin* )      setenv PATH $HOME/.npm/bin:"$PATH"
                breaksw
            case python:
                if ( "$PATH" !~ *$HOME/.local/bin* )    setenv PATH $HOME/.local/bin:"$PATH"
                breaksw
        endsw
    endif
end

set ___X_CMD_TCSH_RC_python_singleton_fp = "$HOME/.x-cmd.root/local/data/pkg/sphere/X/.x-cmd/singleton/python"
if ( -f "$___X_CMD_TCSH_RC_python_singleton_fp" ) then
    set ___X_CMD_TCSH_RC_python_tgtdir = "$HOME/.x-cmd.root/local/data/pkg/sphere/X/`cat $___X_CMD_TCSH_RC_python_singleton_fp`"
    set ___X_CMD_TCSH_RC_os = `uname`
    if ( $___X_CMD_TCSH_RC_os =~ *MINGW* || $___X_CMD_TCSH_RC_os =~ *CYGWIN* || $___X_CMD_TCSH_RC_os =~ *MSYS* ) then
        set ___X_CMD_TCSH_RC_python_binpath = "$___X_CMD_TCSH_RC_python_tgtdir/Scripts"
    else
        set ___X_CMD_TCSH_RC_python_binpath = "$___X_CMD_TCSH_RC_python_tgtdir/bin"
    endif
    if ( -d "$___X_CMD_TCSH_RC_python_binpath" ) then
        if ( "$PATH" !~ *$___X_CMD_TCSH_RC_python_binpath* )  setenv PATH "$___X_CMD_TCSH_RC_python_binpath":"$PATH"
    endif
endif

setenv  ___X_CMD_CD_RELM_0      "$PWD"

# alias x             bash "$HOME/.x-cmd.root/bin/xbin"
# alias ___x_cmd      bash "$HOME/.x-cmd.root/bin/xbin"

alias ___x_cmd      source "$HOME/.x-cmd.root/bin/rc.x.tcsh"
alias x             ___x_cmd


# TODO: in the future, adding the advise

setenv CSH_VERSION "${version}"

if ( -t 1 ) then
    setenv ___X_CMD_RUNMODE 9
else
    setenv ___X_CMD_RUNMODE 0
endif

setenv ___X_CMD_THEME_RELOAD_DISABLE 1

# "$HOME/.x-cmd.root/bin/xbin" prepare alias
if ($?status && $status == 0) then
    # set filec
    # set autolist

    # set autolist = ambiguous
    # set complete = enhance

    # TODO: Consider how to implement c -
    if ( $?OLDPWD ) then
        setenv ___X_CMD_XBINEXP_INITENV_OLDPWD "$OLDPWD"
    else
        setenv ___X_CMD_XBINEXP_INITENV_OLDPWD "$PWD"
    endif

    [ -f "$HOME/.x-cmd.root/boot/alias/c.disable"       ]  ||  alias c     '___x_cmd cd'

    [ -f "$HOME/.x-cmd.root/boot/alias/xx.disable"      ]  ||  alias xx    '___x_cmd xx'
    [ -f "$HOME/.x-cmd.root/boot/alias/xw.disable"      ]  ||  alias xw    '___x_cmd ws'
    [ -f "$HOME/.x-cmd.root/boot/alias/xd.disable"      ]  ||  alias xd    '___x_cmd docker'
    [ -f "$HOME/.x-cmd.root/boot/alias/xg.disable"      ]  ||  alias xg    '___x_cmd git'
    [ -f "$HOME/.x-cmd.root/boot/alias/xp.disable"      ]  ||  alias xp    '___x_cmd pwsh'
    [ -f "$HOME/.x-cmd.root/boot/alias/xwt.disable"     ]  ||  alias xwt   '___x_cmd webtop'

    if ( ! -f "$HOME/.x-cmd.root/boot/alias/co.disable" )  then
        alias ,     '___x_cmd tcsh --sysco'
        alias ，    '___x_cmd tcsh --sysco'
    endif

    # alias ,,    '___x_cmd tcsh --syscoco'
    # alias ，，  '___x_cmd tcsh --syscoco'

    if ( ! -f "$HOME/.x-cmd.root/boot/alias/chat.disable" )  then
        # alias @          '___x_cmd chat --sendalias ""'
        alias @l         '___x_cmd chat --sendalias l'
        alias @lms       '___x_cmd chat --sendalias lms'
        alias @o         '___x_cmd chat --sendalias o'

        alias @gpt       '___x_cmd chat --sendalias gpt'
        alias @gpt3      '___x_cmd chat --sendalias gpt3'
        alias @gpt4      '___x_cmd chat --sendalias gpt4'
        alias @gpt4t     '___x_cmd chat --sendalias gpt4t'
        alias @gpt4om    '___x_cmd chat --sendalias gpt4om'
        alias @gpto1     '___x_cmd chat --sendalias gpto1'
        alias @gpto1m    '___x_cmd chat --sendalias gpto1m'
        alias @gh        '___x_cmd chat --sendalias gh'

        alias @gemini    '___x_cmd chat --sendalias gemini'
        alias @mistral   '___x_cmd chat --sendalias mistral'
        alias @kimi      '___x_cmd chat --sendalias kimi'
    endif
    # eval "`___x_cmd chat --aliasinit --cshcode`"

    #  writer, w
    if ( ! -f "$HOME/.x-cmd.root/boot/alias/writer.disable" )  then
        alias @zh        '___x_cmd writer --sendalias zh'
        alias @en        '___x_cmd writer --sendalias en'
    endif

endif

# advise
if ( $?___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL ) then
    if ( "$___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL" == 1 ) then
        eval `___x_cmd advise complete tcsh code`
    endif
endif

