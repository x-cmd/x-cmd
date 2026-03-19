
export def --env ___x_cmd___rcnu_addp_prepend [ element ] {
    if not ( $element in $env.PATH ) {
        $env.PATH = ( $element | append $env.PATH | str join (char esep) )
    }
}

export def --env ___x_cmd___rcnu_addp_append [ element ] {
    if not ( $element in $env.PATH ) {
        # $env.PATH = ( $env.PATH | prepend args )
        $env.PATH = ( $env.PATH | split row (char esep) | append $element )
    }
}

export def --env ___x_cmd___rcnu_addpifd [ element ] {
    if ( $element | path exists ) {
        ___x_cmd___rcnu_addp_prepend $element
    }
}

export def --env ___x_cmd___rcnu_addpifh [ cmd, element ] {
    if not ( which $cmd | is-empty ) {
        ___x_cmd___rcnu_addp_prepend $element
    }
}

export def --env ___x_cmd___rcnu_addpython [ ...args ] {
    ___x_cmd___rcnu_addpifh python     $"($env.HOME)/.local/bin"
    let singleton_fp = $"($env.___X_CMD_ROOT)/local/data/pkg/sphere/X/.x-cmd/singleton/python"
    if ( $singleton_fp | path exists ) {
        let tgtdir = $"($env.___X_CMD_ROOT)/local/data/pkg/sphere/X/(cat $singleton_fp)"
        if ( $nu.os-info.name == "windows" ) {
            let binpath = ( $tgtdir | path join Scripts)
            ___x_cmd___rcnu_addpifd $binpath
            } else {
            let binpath = ( $tgtdir | path join bin)
            ___x_cmd___rcnu_addpifd $binpath
        }
    }
}


export-env {
    if ( $"($env.___X_CMD_ROOT)/boot/pixi" | path exists ) {
        ___x_cmd___rcnu_addp_append $"($env.HOME)/.pixi/bin"
    }

    ___x_cmd___rcnu_addp_prepend       $"($env.___X_CMD_ROOT)/bin"
    ___x_cmd___rcnu_addp_prepend       $"($env.___X_CMD_ROOT)/local/data/pkg/sphere/X/l/j/h/bin"

    ___x_cmd___rcnu_addpifd            $"($env.HOME)/.cargo/bin"
    ___x_cmd___rcnu_addpifh go         $"($env.HOME)/go/bin"
    ___x_cmd___rcnu_addpifh done       $"($env.HOME)/.done/bin"
    ___x_cmd___rcnu_addpifh bun        $"($env.HOME)/.bun/bin"
    ___x_cmd___rcnu_addpifh npm        $"($env.HOME)/.npm/bin"
    ___x_cmd___rcnu_addpython

    $env.___X_CMD_CO_NOEVAL = 1

    if $nu.is-interactive {
        $env.___X_CMD_RUNMODE = 9
    } else {
        $env.___X_CMD_RUNMODE = 0
    }

    $env.___X_CMD_REAL_CALLER_SHELL = "nu"

    $env.___X_CMD_CD_RELM_0 = $env.PWD
}

export def --env --wrapped ___x_cmd_nu_rc_xbinexp [ ...args ] {
    $env.___X_CMD_XBINEXP_FP = $"($env.___X_CMD_ROOT)/local/data/xbinexp/nu/($nu.pid)_(random int)"
    # mkdir $env.___X_CMD_XBINEXP_FP

    if OLDPWD in $env {
        $env.___X_CMD_XBINEXP_INITENV_OLDPWD = $env.OLDPWD
    } else {
        $env.___X_CMD_XBINEXP_INITENV_OLDPWD = $env.PWD
    }

    if $nu.is-interactive {
        $env.___X_CMD_RUNMODE = 9
    } else {
        $env.___X_CMD_RUNMODE = 0
    }

    $env.___X_CMD_REAL_CALLER_SHELL = "nu"

    ___x_cmdexe_exp ...$args

    let exit_code = $env.LAST_EXIT_CODE

    # bash -c $"ls  ($env.___X_CMD_XBINEXP_FP)"

    if not ( $env.___X_CMD_XBINEXP_FP | path exists ) {
        $env.LAST_EXIT_CODE = $exit_code
        return
    }

    let data = ls $env.___X_CMD_XBINEXP_FP | each { |i|
        mut keyname = ""
        if (( $nu.os-info.name == "windows" ))  {
            $keyname = ( $i.name | str replace --regex "^.+\\\\" "" | str replace --regex "^.*?_" "")
            if ( $keyname in [ "PATH", "PWD"] ) {
                return {
                    key: $keyname,
                    value: ( ( open $i.name --raw | path split | get 0 ) + :\ + ( open $i.name --raw | path split | skip 1 | path join ) )
                }
            }
        } else {
            $keyname = ($i.name | str replace --regex "^.+/" "" | str replace --regex "^.*?_" "")
        }

        return {
            key: $keyname,
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

    $env.LAST_EXIT_CODE = $exit_code
}

# export alias ___x_cmd   = bash $"($env.___X_CMD_ROOT)/bin/xbinexp"
# export alias x          = bash $"($env.___X_CMD_ROOT)/bin/xbinexp"

export def --env --wrapped ___x_cmdexe_exp [ ...args ] {
    if ( $nu.os-info.name == "windows" ) {
        cmd /c  $"($env.___X_CMD_ROOT)/bin/___x_cmdexe_exp.bat" ...$args
    } else {
        bash    $"($env.___X_CMD_ROOT)/bin/___x_cmdexe_exp"     ...$args
    }
}

export def --env --wrapped ___x_cmd [ ...args ] {
    if ((($args | length) > 0) and ( ($args | get 0) == "cd" )) {
        ___x_cmd_cd ...( $args | skip 1 )
        return
    }

    if ( $nu.os-info.name == "windows" ) {
        cmd /c  $"($env.___X_CMD_ROOT)/bin/___x_cmdexe_exp.bat" ...$args
    } else {
        bash    $"($env.___X_CMD_ROOT)/bin/___x_cmdexe_exp"     ...$args
    }
}

export alias x  = ___x_cmd

export def --env --wrapped ___x_cmd_cd [ ...args ] {
    if ($args | length) == 0 {
        ___x_cmd_nu_rc_xbinexp cd
        return
    }

    let original_dir = $env.PWD
    mut oldpwd_dir = $env.PWD
    if OLDPWD in $env { $oldpwd_dir = $env.OLDPWD }

    let arg1 = ($args | get 0)
    mut param = ( $args | skip 1 )

    if $arg1 == "-" {
        cd -
        ___x_cmd_nu_rc_xbinexp cd --history top $env.PWD
    } else if $arg1 in ["-b", "-f"] {
        if ($args | length ) > 2 {
            ___x_cmd_nu_rc_xbinexp cd ($args | get 0) ($args | get 1)
            $param = ( $args | skip 2 )
        } else {
            ___x_cmd_nu_rc_xbinexp cd ($args | get 0)
        }
    } else if $arg1 =~ "[-|--][a-zA-Z]+$" {
        ___x_cmd_nu_rc_xbinexp cd ...$args
        return
    } else {
        ___x_cmd_nu_rc_xbinexp cd $arg1
    }

    if ($param | length) == 0 {
        return
    }

    if ( $param | get 0 ) in ["-", "--"] {
        $param = ( $args | skip 1 )
    }

    if ($param | length) > 0 {
        let cd_args = ( $param | str join " " )
        printf "%s\n" $"- I|cd: Change the directory [($env.PWD)] to execute -> '($cd_args)'" | print --stderr
        ^$nu.current-exe -c $cd_args

        # if ( $param | get 0 ) in (help commands | where command_type in ['builtin'] | get name) {
        #     ^$nu.current-exe -c ( $param | str join " " )
        # } else {
        #     run-external ( $param | get 0 ) ...( $param | skip 1 )
        # }
    } else {
        return
    }

    ___x_cmd_nu_rc_xbinexp cd $original_dir
    $env.OLDPWD = $oldpwd_dir
    return
}
