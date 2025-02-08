# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"
___x_cmd_pkg_shim_gen_app(){
    local helix_runtime="$___X_CMD_PKG___META_TGT/runtime"
    ___x_cmd_pkg_shim_gen \
        --mode adaptive --code sh               \
        --var "HELIX_RUNTIME=${helix_runtime}"  \
        --bin_dir bin                           \
        --bin_file  "$@"                || return
    [ "$___X_CMD_PKG___META_OS" != "win" ] || {
        ___x_cmd_pkg_shim_gen \
        --mode adaptive --code bat              \
        --var "HELIX_RUNTIME=${helix_runtime}"  \
        --bin_dir bin                           \
        --bin_file "$@"                 || return
    }
}
___x_cmd_pkg_shim_gen_app hx
