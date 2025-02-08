# shellcheck shell=dash
___x_cmd_pkg_boot_bash_preexec(){
    export __bp_enable_subshells="true"
    . "$___X_CMD_PKG___META_TGT/bash-preexec.sh"
}
___x_cmd_pkg_boot_bash_preexec
