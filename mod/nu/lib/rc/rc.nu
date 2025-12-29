
if ($env.HOME | is-empty) {
    $env.HOME = $nu.home-path
}

# const ___X_CMD_ROOT = $"($nu.home-path)/.x-cmd.root"  # To dev

$env.___X_CMD_ROOT = $___X_CMD_ROOT

use $"($___X_CMD_ROOT)/local/data/nu/core.nu" *

if ( $"($___X_CMD_ROOT)/local/cfg/theme/use/nu/default.nu" | path exists ) {
    source $"($___X_CMD_ROOT)/local/cfg/theme/use/nu/default.nu"
}

if ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? | is-empty) or ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? != "0" ) {
    if not ( source $"($___X_CMD_ROOT)/local/cache/advise/bootcode/v0.0.0.nu" ) {
        ___x_cmd advise complete nu code | save -f $"($___X_CMD_ROOT)/local/cache/advise/bootcode/v0.0.0.nu"
        source $"($___X_CMD_ROOT)/local/cache/advise/bootcode/v0.0.0.nu"
    }

    if ( $"($___X_CMD_ROOT)/local/cache/advise/addon/complete.nu" | path exists ) {
        source $"($___X_CMD_ROOT)/local/cache/advise/addon/complete.nu"
    }
}

module ___x_cmd_shortcut_co {
    export alias ","        = ___x_cmd nu "--sysco"
    export alias "，"       = ___x_cmd nu "--sysco"
}

module ___x_cmd_shortcut_coco {
    export alias ",,"        = ___x_cmd nu "--syscoco"
    export alias "，，"      = ___x_cmd nu "--syscoco"
}

const ___x_cmd_shortcut = if ( $"($___X_CMD_ROOT)/local/cache/shortcut/compile/shortcut.nu" | path exists) {
        $"($___X_CMD_ROOT)/local/cache/shortcut/compile/shortcut.nu"
    } else {
        null
    }
use $___x_cmd_shortcut *

const ___x_cmd_shortcut = if not ( $"($___X_CMD_ROOT)/boot/alias/co.disable" | path exists) { "___x_cmd_shortcut_co" } else { null }
use $___x_cmd_shortcut [ ',', '，' ]

const ___x_cmd_shortcut = if not ( $"($___X_CMD_ROOT)/boot/alias/coco.disable" | path exists) { "___x_cmd_shortcut_coco" } else { null }
use $___x_cmd_shortcut [ ',,', '，，' ]

