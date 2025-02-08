# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"
___x_cmd_pkg_shim_gen_app(){
    ___x_cmd_pkg_shim_gen \
        --mode app --code sh            \
        --var "RUNEWIDTH_EASTASIAN=0"   \
        --bin_dir bin                   \
        --bin_file  "$@"                || return
    [ "$___X_CMD_PKG___META_OS" != "win" ] || {
        ___x_cmd_pkg_shim_gen \
        --mode app --code bat           \
        --var "RUNEWIDTH_EASTASIAN=0"   \
        --bin_dir bin                   \
        --bin_file "$@"                 || return
    }
}
___x_cmd_pkg_shim_gen_app spf

