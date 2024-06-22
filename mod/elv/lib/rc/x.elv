var ___X_CMD_ELV_RC_XBINEXP = $E:HOME/.x-cmd.root/bin/xbinexp

use re
use os

fn x {  |@a|
    if ( not (has-env OLDPWD) ) {
        set-env OLDPWD $E:PWD
    }

    set-env ___X_CMD_IS_INTERACTIVE_FORCE   1
    set-env ___X_CMD_THEME_RELOAD_DISABLE   1

    set-env ___X_CMD_XBINEXP_FP $E:HOME/.x-cmd.root/local/data/xbinexp/elv/$"pid"_(randint 65535)

    # os:mkdir-all &perm=0o700 $E:___X_CMD_XBINEXP_FP
    # mkdir -p $E:___X_CMD_XBINEXP_FP
    # touch $E:___X_CMD_XBINEXP_FP/_

    if (has-env OLDPWD) {
        set-env ___X_CMD_XBINEXP_INITENV_OLDPWD $E:OLDPWD
    } else {
        set-env ___X_CMD_XBINEXP_INITENV_OLDPWD $pwd
    }

    unset-env ___X_CMD_XBINEXP_EVAL

    try {
        bash $___X_CMD_ELV_RC_XBINEXP    $@a
    } finally {
        if ( not (os:is-dir $E:___X_CMD_XBINEXP_FP) ) { return }

        var fp
        var varname
        var val

        for fp [ $E:___X_CMD_XBINEXP_FP/* ] {
            set varname = ( re:replace &longest=$true "^.*/[^_]*_" "" $fp )
            set val = (slurp <$fp)
            if ( eq $varname "PWD" ) {
                set pwd = $val
            } else {
                set-env $varname $val
            }
        }

        if (re:match 'xbinexp/elv' $E:___X_CMD_XBINEXP_FP) {
            rm -rf $E:___X_CMD_XBINEXP_FP
        }

        # But this only works in the directory ...
        if (has-env ___X_CMD_XBINEXP_EVAL) {
            eval $E:___X_CMD_XBINEXP_EVAL
        }
    }
}


fn xw { |@a| x ws               $@a ; }
fn xg { |@a| x git              $@a ; }
fn xd { |@a| x docker           $@a ; }

fn c {
    |@a|

    var c = (count $a)
    if ( == $c 1 ) {
        if ( eq $a[0] "-" ) {
            if (has-env OLDPWD) {
                cd $E:OLDPWD
            }
            return
        }

        if ( os:is-dir $a[0] ) {
            cd $a[0]
            return
        }
    }

    x cd $@a
}

fn co {
    |@a|
    x:x elv --sysco $@a
}

fn init {
    set-env OLDPWD $pwd
    set-env ___X_CMD_CD_RELM_0 $pwd

    set before-chdir = [
        {
            |dir|
            set-env OLDPWD $pwd
        }
        $@before-chdir
    ]

    if (has-value $paths $E:HOME/.x-cmd.root/bin) {
        # set E:PATH = $E:HOME/.x-cmd.root/bin:$E:PATH
        set paths = [ $E:HOME/.x-cmd.root/bin                         $@paths ]
    }

    if (has-value $paths $E:HOME/.x-cmd.root/global/data/bin/l/j/h/bin) {
        set paths = [ $E:HOME/.x-cmd.root/global/data/bin/l/j/h/bin   $@paths ]
    }

    if ( os:is-regular $E:HOME/.config/elvish/lib/a.elv ) {
        use a
        edit:add-var a: $a:
    }

    if (not (os:is-regular $E:HOME/.x-cmd.root/local/data/elv/config/readline-binding.disable ) ) {
        use readline-binding
        edit:add-var readline-binding $readline-binding:
    }

    # TODO: activate advise
    # TODO: activate theme

    edit:add-vars [
        &x1~=$x~
        &x~=$x~
        &c~=$c~
        &xw~=$xw~
        &xg~=$xg~
        &xd~=$xd~
        &init~=$init~
        &,=$co~
    ]
}
