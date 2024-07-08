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

fn xx   { |@a| x xx               $@a ; }
fn xw   { |@a| x ws               $@a ; }

fn xd   { |@a| x docker           $@a ; }
fn xg   { |@a| x git              $@a ; }
fn xp   { |@a| x pwsh             $@a ; }

fn co   { |@a| x:x elv --sysco    $@a ; }
fn coco { |@a| x:x elv --syscoco  $@a ; }

fn addp {       |p|         if ( not (has-value $paths $p) )    {   set paths = [ $p $@paths ] } }
fn addpifh {    |bin p|     if ( has-external $bin )            {   addp $p     } }
fn addpifd {    |p|         if ( os:is-dir $p )                 {   addp $p     } }

# defintion of @<xxx> is in module a

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

    if ( os:is-regular $E:HOME/.x-cmd.root/ctrl/pixi ) {
        set paths = [ $@paths $E:HOME/.pixi/bin ]
    }

    addp                $E:HOME/.x-cmd.root/bin
    addp                $E:HOME/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin

    # TODO: foreach pkg/path pkg/env, then add path and env
    addpifd             $E:HOME/.cargo/bin
    addpifh  go         $E:HOME/go/bin

    addpifh  python     $E:HOME/.local/bin

    addpifh  deno       $E:HOME/.deno/bin
    addpifh  bun        $E:HOME/.bun/bin
    addpifh  npm        $E:HOME/.npm/bin

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
        &xx~=$xx~
        &xd~=$xd~
        &xg~=$xg~
        &xp~=$xp~
        &init~=$init~
        &,=$co~
        &，=$co~
        &,,=$coco~
        &，，=$coco~
    ]
}
