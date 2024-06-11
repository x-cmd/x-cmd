
export-env {
    if not ($"($env.HOME)/.x-cmd.root/bin" in $env.PATH) {
        $env.PATH = ( $env.PATH | prepend $"($env.HOME)/.x-cmd.root/bin" )
    }

    if not ($"($env.HOME)/.x-cmd.root/global/data/bin/l/j/h/bin" in $env.PATH) {
        $env.PATH = ( $env.PATH | prepend $"($env.HOME)/.x-cmd.root/global/data/bin/l/j/h/bin" )
    }

    $env.___X_CMD_CO_NOEVAL = 1
}

export def --env x [ ...args ] {
    $env.___X_CMD_XBINEXP_FP = $"($env.HOME)/.x-cmd.root/local/data/xbinexp/nu/($nu.pid)_(random int)"
    mkdir $env.___X_CMD_XBINEXP_FP
    $env.___X_CMD_XBINEXP_INITENV_OLDPWD = $env.OLDPWD

    $env.___X_CMD_IS_INTERACTIVE_FORCE = 1
    $env.___X_CMD_THEME_RELOAD_DISABLE = 1

    bash $"($env.HOME)/.x-cmd.root/bin/xbinexp" ...$args

    let exit_code = $env.LAST_EXIT_CODE

    # bash -c $"ls  ($env.___X_CMD_XBINEXP_FP)"

    let fp_pwd = $"($env.___X_CMD_XBINEXP_FP)/PWD"
    if ( $fp_pwd | path exists  ) {
        let pwd: string = ( open $fp_pwd --raw )
        cd $pwd
        rm -f $fp_pwd
    }

    let fp_path = $"($env.___X_CMD_XBINEXP_FP)/PATH"
    if ( $fp_path | path exists  ) {
        let pathstr: string = ( open $fp_path --raw )
        $env.PATH = $pathstr
        rm -f $fp_path
    }

    let data = ls $env.___X_CMD_XBINEXP_FP | each { |i|
        {
            key:($i.name | str replace --regex "^.+/" "" | str replace --regex "^.*?_" ""),
            value: ( open $i.name --raw )
        }
    }

    # TODO: load-env on ...
    for $i in $data {
        load-env { $i.key: $i.value }
    }

    let all_file = (ls $env.___X_CMD_XBINEXP_FP | each { |i| $i.name } )

    if ($all_file | length ) > 0 {
        rm ...(ls $env.___X_CMD_XBINEXP_FP | each { |i| $i.name } )
    }

    rm -f $env.___X_CMD_XBINEXP_FP
}

export alias xw     = x ws
export alias xg     = x git
# export alias xd     = x docker

export alias ","    = x nu "--sysco"

export def --env c [ ...args ] {
    if  ($args | length) == 0 {
        x cd
        return
    }
    if ($args | get 0) == "-" {
        cd -
        return
    }
    if ($args | get 0) == "~" {
        cd ~
        return
    }
    x cd ...$args
}

export def --env @ [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = ""
    x chat "--send" ...$args
}

export def --env @o [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = o
    x chat "--send" ...$args
}

export def --env @gemini [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = gemini
    x chat "--send" ...$args
}

export def --env @kimi [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = kimi
    x chat "--send" ...$args
}

export def --env @gpt [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = gpt
    x chat "--send" ...$args
}

export def --env @gpt3 [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = gpt3
    x chat "--send" ...$args
}

export def --env @gpt4 [ ...args ] {
    $env.___X_CMD_CHAT_NORMAL_ALIAS = "gpt4"
    x chat "--send" ...$args
}


