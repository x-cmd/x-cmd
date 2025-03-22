
use $"($nu.home-path)/.x-cmd.root/local/data/nu/core.nu" *

if ( $"($nu.home-path)/.x-cmd.root/local/cfg/theme/use/nu/default.nu" | path exists ) {
    source $"($nu.home-path)/.x-cmd.root/local/cfg/theme/use/nu/default.nu"
}

if ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? | is-empty) or ( $env.___X_CMD_ADVISE_ACTIVATION_ON_NON_POSIX_SHELL? != "0" ) {
    source $"($nu.home-path)/.x-cmd.root/local/data/nu/advise.nu"
}


module ___x_cmd_aliases {
    export alias c         = ___x_cmd_cd

    export alias xx         = ___x_cmd xx
    export alias xw         = ___x_cmd ws

    export alias xd         = ___x_cmd docker
    export alias xg         = ___x_cmd git
    export alias xp         = ___x_cmd pwsh
    export alias xwt        = ___x_cmd webtop

    export alias ","        = ___x_cmd nu "--sysco"
    export alias "，"       = ___x_cmd nu "--sysco"

    export alias ",,"        = ___x_cmd nu "--syscoco"
    export alias "，，"      = ___x_cmd nu "--syscoco"

    export module ___x_cmd_aliases_chat {
        export alias @          = ___x_cmd chat --sendalias ""
        export alias @l         = ___x_cmd chat --sendalias l
        export alias @lms       = ___x_cmd chat --sendalias lms
        export alias @o         = ___x_cmd chat --sendalias o

        export alias @gpt       = ___x_cmd chat --sendalias gpt
        export alias @gpt3      = ___x_cmd chat --sendalias gpt3
        export alias @gpt4      = ___x_cmd chat --sendalias gpt4
        export alias @gpt4t     = ___x_cmd chat --sendalias gpt4t
        export alias @gpt4om    = ___x_cmd chat --sendalias gpt4om
        export alias @gpto1     = ___x_cmd chat --sendalias gpto1
        export alias @gpto1m    = ___x_cmd chat --sendalias gpto1m
        export alias @gh        = ___x_cmd chat --sendalias gh

        export alias @gemini    = ___x_cmd chat --sendalias gemini
        export alias @mistral   = ___x_cmd chat --sendalias mistral
        export alias @kimi      = ___x_cmd chat --sendalias kimi
        export alias @ds        = ___x_cmd chat --sendalias ds
        export alias @dsr1      = ___x_cmd chat --sendalias dsr1
        export alias @grok      = ___x_cmd chat --sendalias grok
    }
    # writer
    export alias @zh        = ___x_cmd writer --sendalias zh
    export alias @en        = ___x_cmd writer --sendalias en
}

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/c.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias c

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xx.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xx

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xw.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xw

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xd.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xd

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xg.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xg

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xp.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xp

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/xwt.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias xwt

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/co.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias [ ',', '，' ]

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/coco.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias [ ',,', '，，' ]

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/chat.disable" | path exists) { "___x_cmd_aliases" } else { null }
use ___x_cmd_aliases ___x_cmd_aliases_chat *

const ___x_cmd_alias = if not ( $"($nu.home-path)/.x-cmd.root/boot/alias/writer.disable" | path exists) { "___x_cmd_aliases" } else { null }
use $___x_cmd_alias [ '@zh', '@en' ]
