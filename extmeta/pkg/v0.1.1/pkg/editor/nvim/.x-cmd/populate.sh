# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_nvim_populate(){
    local bin_suffix=
    [ "$___X_CMD_PKG___META_OS" != "win" ] || bin_suffix=.exe

    local source="$___X_CMD_PKG___META_TGT/bin"
    local target="$___X_CMD_PKG___META_TGT/shim_bin"

    x mkdirp "$target"

    x_cmd_pkg:info --source "$source" --shim_bin "$target" "shim gen sh code"
    ___x_cmd_pkg_shim_gen                             \
        --mode app --code sh                          \
        --bin_dir bin --bin_file "nvim${bin_suffix}"  \
    || return

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        x_cmd_pkg:info --source "$source" --shim_bin "$target" "shim gen bat code"
        ___x_cmd_pkg_shim_gen                            \
            --mode app --code bat                        \
            --bin_dir bin --bin_file "nvim${bin_suffix}" \
        || return
    fi
}

___x_cmd_pkg_nvim_populate || return

