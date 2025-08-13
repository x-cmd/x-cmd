
use re
use os
use platform
use runtime
use str

# if repl set-env ___X_CMD_RUNMODE 9 # chatty
# if repl but less chatty set-env ___X_CMD_RUNMODE 5 # manual
# if script ___X_CMD_RUNMODE 0

if (not-eq $runtime:effective-rc-path $nil) {
    set-env ___X_CMD_RUNMODE    9
    if (not (has-env ___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL)) {
        set-env ___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL 1
    }
} else {
    set-env ___X_CMD_RUNMODE    0
}

fn ___x_cmd { |@a|
    if ( not (has-env OLDPWD) ) {
        set-env OLDPWD $E:PWD
    }

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
    set-env ___X_CMD_REAL_CALLER_SHELL "elvish"

    try {
        if (not-eq $platform:os "windows") {
            bash $E:HOME/.x-cmd.root/bin/___x_cmdexe_exp $@a
        } else {
            $E:HOME/.x-cmd.root/bin/___x_cmdexe_exp.bat $@a
        }
    } finally {
        if ( not (os:is-dir $E:___X_CMD_XBINEXP_FP) ) { return }

        var fp
        var varname
        var val

        for fp [ $E:___X_CMD_XBINEXP_FP/* ] {
            set varname = ( re:replace &longest=$true "^.*/[^_]*_" "" $fp )
            set val = (cat $fp)
            if ( eq $varname "PWD" ) {
                if (and $platform:is-windows (re:match "^/[A-Za-z]/" $val) ) {
                    set pwd = $val[1]:/$val[3..]
                } else {
                    set pwd = $val
                }
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

        unset-env ___X_CMD_XBINEXP_FP
        unset-env ___X_CMD_XBINEXP_INITENV_OLDPWD
        unset-env ___X_CMD_REAL_CALLER_SHELL
    }
}

fn ___x_cmd_cd { |@a|

    var original_oldpwd = $E:OLDPWD
    var original_dir = $pwd
    var args
    if ( == (count $a) 0 ) {
        ___x_cmd cd
        return
    } elif (eq $a[0] "-") {
        ___x_cmd cd $E:OLDPWD
        set args = $a[1..]
    } else {
        if (or (eq $a[0] "-b") (eq $a[0] "-f")) {
            ___x_cmd cd $a[0] $a[1]
            set args = $a[2..]
        } elif (re:match "^-.*" $a[0]) {
            ___x_cmd cd $@a
            return
        } else {
            ___x_cmd cd $a[0]
            set args = $a[1..]
        }
    }

    if ( > (count $args) 0) {
        if (or (eq $args[0] "-") (eq $args[0] "--")) {
            set args = $args[1..]
        }

        if (not (> (count $args) 0)) {
            return
        }

        echo "I|cd: Change the directory to ["$pwd"] to execute -> '"(str:join " " [(each {|a| put $a} $args)])"'"
        eval (str:join " " [(each {|a| put $a} $args)])
        ___x_cmd cd $original_dir
        set-env OLDPWD $original_oldpwd
    }
}

fn x { |@a|
    if (eq $a[0] "cd") {
        var args = $a[1..]
        ___x_cmd_cd $@args
        return
    }
    ___x_cmd $@a
}


fn co   { |@a| ___x_cmd elv --sysco     $@a ; }
fn coco { |@a| ___x_cmd elv --syscoco   $@a ; }

fn ___x_cmd___rcelv_addp_prepend {  |p|     if ( not (has-value $paths $p) )    {   set paths = [ $p $@paths ]  } }
fn ___x_cmd___rcelv_addp_append {   |p|     if ( not (has-value $paths $p) )    {   set paths = [ $@paths $p ]  } }
fn ___x_cmd___rcelv_addpifh {       |bin p| if ( has-external $bin )            {   ___x_cmd___rcelv_addp_prepend $p    } }
fn ___x_cmd___rcelv_addpifd {       |p|     if ( os:is-dir $p )                 {   ___x_cmd___rcelv_addp_prepend $p    } }
fn ___x_cmd___rcelv_addpython {
    ___x_cmd___rcelv_addpifh python $E:HOME/.local/bin

    var singleton_fp = $E:HOME/.x-cmd.root/local/data/pkg/sphere/X/.x-cmd/singleton/python
    if (os:is-regular $singleton_fp) {
        var tgtdir = $E:HOME/.x-cmd.root/local/data/pkg/sphere/X/(cat $singleton_fp)
        var binpath
        if (eq $platform:os "windows") {
            set binpath = $tgtdir/Scripts
        } else {
            set binpath = $tgtdir/bin
        }
        ___x_cmd___rcelv_addpifd $binpath
    }
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

    if ( os:is-regular $E:HOME/.x-cmd.root/boot/pixi ) {
        ___x_cmd___rcelv_addp_append    $E:HOME/.pixi/bin
    }

    ___x_cmd___rcelv_addp_prepend       $E:HOME/.x-cmd.root/bin
    ___x_cmd___rcelv_addp_prepend       $E:HOME/.x-cmd.root/local/data/pkg/sphere/X/l/j/h/bin

    # TODO: foreach pkg/path pkg/env, then add path and env
    ___x_cmd___rcelv_addpifd            $E:HOME/.cargo/bin
    ___x_cmd___rcelv_addpifh  go        $E:HOME/go/bin
    ___x_cmd___rcelv_addpifh  deno      $E:HOME/.deno/bin
    ___x_cmd___rcelv_addpifh  bun       $E:HOME/.bun/bin
    ___x_cmd___rcelv_addpifh  npm       $E:HOME/.npm/bin
    ___x_cmd___rcelv_addpython

    if ( os:is-regular $E:HOME/.x-cmd.root/local/data/elv/config/readline-binding.enable ) {
        use readline-binding
        edit:add-var readline-binding $readline-binding:
    }

    edit:add-var            x~      $x~

    if (not (os:is-regular  $E:HOME/.x-cmd.root/boot/alias/c.disable    )) {
        edit:add-var        c~      $___x_cmd_cd~
    }

    if (not (os:is-regular  $E:HOME/.x-cmd.root/boot/alias/co.disable   )) {
        edit:add-vars [     &,~=$co~        &，~=$co~       ]
    }
    if (not (os:is-regular  $E:HOME/.x-cmd.root/boot/alias/coco.disable )) {
        edit:add-vars [     &,,~=$coco~     &，，~=$coco~   ]
    }

    if ( eq $E:___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL '1' ) {
        if (not (os:is-regular  $E:HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.elv )) {
            mkdir -p $E:HOME/.x-cmd.root/local/cache/advise/bootcode
            x advise complete elv code > $E:HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.elv
        }
        eval ( slurp < $E:HOME/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.elv )

        if (os:is-regular  $E:HOME/.x-cmd.root/local/cache/advise/addon/complete.elv) {
            eval ( slurp < $E:HOME/.x-cmd.root/local/cache/advise/addon/complete.elv )
        }
    }


    if (os:is-regular  $E:HOME/.x-cmd.root/local/cfg/theme/use/elvish/default.elv) {
        eval ( slurp < $E:HOME/.x-cmd.root/local/cfg/theme/use/elvish/default.elv )
    }
}
