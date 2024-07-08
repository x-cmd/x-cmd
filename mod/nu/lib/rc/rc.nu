

export def --env ___x_cmd_nu_nurc_addpath [ element ] {
    if not ( $element in $env.PATH ) {
        # $env.PATH = ( $env.PATH | prepend args )
        $env.PATH = ( $env.PATH | split row (char esep) | prepend $element )
    }
}

export def --env ___x_cmd_nu_nurc_addpifd [ element ] {
    if ( $element | path exists ) {
        ___x_cmd_nu_nurc_addpath $element
    }
}

export def --env ___x_cmd_nu_nurc_addpifh [ cmd, element ] {
    if not ( which $cmd | is-empty ) {
        ___x_cmd_nu_nurc_addpath $element
    }
}

export-env {
    if ( $"($env.HOME)/.x-cmd.root/ctrl/pixi" | path exists ) {
        ___x_cmd_nu_nurc_addpath $"($env.HOME)/.pixi/bin"
    }

    ___x_cmd_nu_nurc_addpath            $"($env.HOME)/.x-cmd.root/bin"
    ___x_cmd_nu_nurc_addpath            $"($env.HOME)/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin"
    ___x_cmd_nu_nurc_addpifd            $"($env.HOME)/.cargo/bin"

    ___x_cmd_nu_nurc_addpifh go         $"($env.HOME)/go/bin"
    ___x_cmd_nu_nurc_addpifh python     $"($env.HOME)/.local/bin"
    ___x_cmd_nu_nurc_addpifh done       $"($env.HOME)/.done/bin"
    ___x_cmd_nu_nurc_addpifh bun        $"($env.HOME)/.bun/bin"
    ___x_cmd_nu_nurc_addpifh npm        $"($env.HOME)/.npm/bin"


    $env.___X_CMD_CO_NOEVAL = 1
    $env.___X_CMD_IS_INTERACTIVE_FORCE = 1
    $env.___X_CMD_THEME_RELOAD_DISABLE = 1

    $env.___X_CMD_CD_RELM_0 = $env.PWD
}

export def --env --wrapped ___x_cmd_nu_rc_xbinexp [ ...args ] {
    $env.___X_CMD_XBINEXP_FP = $"($env.HOME)/.x-cmd.root/local/data/xbinexp/nu/($nu.pid)_(random int)"
    # mkdir $env.___X_CMD_XBINEXP_FP

    if OLDPWD in $env {
        $env.___X_CMD_XBINEXP_INITENV_OLDPWD = $env.OLDPWD
    } else {
        $env.___X_CMD_XBINEXP_INITENV_OLDPWD = $env.PWD
    }

    $env.___X_CMD_IS_INTERACTIVE_FORCE = 1
    $env.___X_CMD_THEME_RELOAD_DISABLE = 1

    bash $"($env.HOME)/.x-cmd.root/bin/xbinexp" ...$args

    let exit_code = $env.LAST_EXIT_CODE

    # bash -c $"ls  ($env.___X_CMD_XBINEXP_FP)"

    if not ( $env.___X_CMD_XBINEXP_FP | path exists ) {
        $env.LAST_EXIT_CODE = exit_code
        return
    }

    let data = ls $env.___X_CMD_XBINEXP_FP | each { |i|
        {
            key:($i.name | str replace --regex "^.+/" "" | str replace --regex "^.*?_" ""),
            value: ( open $i.name --raw )
        }
    }

    # TODO: load-env on ...
    for $i in $data {
        if ( $i.key == "PWD" ) {
            cd $i.value
        } else if ($i.key == "PATH") {
            $env.PATH = ( $i.value | split row : )
            # TODO: We might need to handle the PATH in windows git-bash ...
        } else {
            # Check whether is write to add path
            load-env { $i.key: $i.value }
        }
    }

    let all_file = (ls $env.___X_CMD_XBINEXP_FP | each { |i| $i.name } )

    if ($all_file | length ) > 0 {
        rm ...(ls $env.___X_CMD_XBINEXP_FP | each { |i| $i.name } )
    }

    rm -f $env.___X_CMD_XBINEXP_FP

    $env.___X_CMD_XBINEXP_FP = ""

    $env.LAST_EXIT_CODE = exit_code
}

export alias ___x_cmd   = bash $"($env.HOME)/.x-cmd.root/bin/xbinexp"
export alias x          = bash $"($env.HOME)/.x-cmd.root/bin/xbinexp"

export def --env --wrapped c [ ...args ] {
    if  ($args | length) == 0 {
        ___x_cmd_nu_rc_xbinexp cd
        return
    }

    let arg1 = ($args | get 0)

    if $arg1 == "-" {                   cd -
    } else if $arg1 == "~" {            cd ~
    } else if ($arg1 | path exists) {   cd $arg1
    } else {
        ___x_cmd_nu_rc_xbinexp cd ...$args
    }
}


export alias xx         = ___x_cmd xx
export alias xw         = ___x_cmd ws

export alias xd         = ___x_cmd docker
export alias xg         = ___x_cmd git
export alias xp         = ___x_cmd pwsh


export alias ","        = ___x_cmd nu "--sysco"
export alias "，"       = ___x_cmd nu "--sysco"

export alias ",,"        = ___x_cmd nu "--syscoco"
export alias "，，"      = ___x_cmd nu "--syscoco"

# chat
export alias @          = ___x_cmd chat --sendalias ""
export alias @l         = ___x_cmd chat --sendalias l
export alias @lms       = ___x_cmd chat --sendalias lms
export alias @o         = ___x_cmd chat --sendalias o

export alias @gpt       = ___x_cmd chat --sendalias gpt
export alias @gpt3      = ___x_cmd chat --sendalias gpt3
export alias @gpt4      = ___x_cmd chat --sendalias gpt4

export alias @kimi      = ___x_cmd chat --sendalias kimi
export alias @gemini    = ___x_cmd chat --sendalias gemini
export alias @mistral   = ___x_cmd chat --sendalias mistral

# writer
export alias @zh        = ___x_cmd writer --sendalias zh
export alias @en        = ___x_cmd writer --sendalias en
