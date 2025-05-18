
if ($env.HOME | is-empty) {
    $env.HOME = $nu.home-path
}

use $"($nu.home-path)/.x-cmd.root/local/data/nu/core.nu" *

if ( $"($nu.home-path)/.x-cmd.root/local/cfg/theme/use/nu/default.nu" | path exists ) {
    source $"($nu.home-path)/.x-cmd.root/local/cfg/theme/use/nu/default.nu"
}

if ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? | is-empty) or ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? != "0" ) {
    if ( $"($nu.home-path)/.x-cmd.root/local/cache/advise/addon/complete.nu" | path exists ) {
        source $"($nu.home-path)/.x-cmd.root/local/cache/advise/addon/complete.nu"
    }

    source $"($nu.home-path)/.x-cmd.root/local/cache/advise/bootcode/v0.0.0.nu"
}


module ___x_cmd_shortcut_co {
    export alias ","        = ___x_cmd nu "--sysco"
    export alias "，"       = ___x_cmd nu "--sysco"
}

module ___x_cmd_shortcut_coco {
    export alias ",,"        = ___x_cmd nu "--syscoco"
    export alias "，，"      = ___x_cmd nu "--syscoco"
}

const ___x_cmd_shortcut = if ( $"($nu.home-path)/.x-cmd.root/local/cache/shortcut/compile/shortcut.nu" | path exists) {
        $"($nu.home-path)/.x-cmd.root/local/cache/shortcut/compile/shortcut.nu"
    } else {
        null
    }
use $___x_cmd_shortcut *

const ___x_cmd_shortcut = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/co.disable" | path exists) { "___x_cmd_shortcut_co" } else { null }
use $___x_cmd_shortcut [ ',', '，' ]

const ___x_cmd_shortcut = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/coco.disable" | path exists) { "___x_cmd_shortcut_coco" } else { null }
use $___x_cmd_shortcut [ ',,', '，，' ]

