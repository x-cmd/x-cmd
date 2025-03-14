# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"
___x_cmd_pkg_shim_gen_app(){
    if [ "$___X_CMD_PKG___META_OS" != "win" ];then
        ___x_cmd_pkg_shim_gen \
            --mode app --code sh            \
            --bin_dir bin                   \
            --bin_file  "$@"                || return
    else
        ___x_cmd_pkg_shim_gen \
            --mode app --code sh            \
            --bin_file  "$@"                || return
        ___x_cmd_pkg_shim_gen \
            --mode app --code bat           \
            --bin_file "$@"                 || return
    fi
}
___x_cmd_pkg_shim_gen_app hurl
