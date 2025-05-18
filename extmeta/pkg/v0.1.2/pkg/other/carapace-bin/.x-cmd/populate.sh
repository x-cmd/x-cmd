# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_carapace_bin_populate(){
    local tree=; local download_file_ext=;
    ___x_cmd_pkg___attr                   \
        "$___X_CMD_PKG___META_NAME" "$___X_CMD_PKG___META_VERSION"  \
        "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH"         \
        "download_file_ext,tree"                                         || return

    local ball="$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}.${tree}.${download_file_ext}"
    local unpack_dir="$___X_CMD_PKG___META_TGT"
    x_cmd_pkg:info  --ball "$___X_CMD_PKG_DOWNLOAD_PATH/$___X_CMD_PKG___META_NAME/${___X_CMD_PKG___META_VERSION}.${tree}.${download_file_ext}" --target_dir "$unpack_dir" "Unpacking"
    ___X_CMD_ZUZ_QUIET=1 ___x_cmd uzr "$ball" "$unpack_dir" || {
        ___x_cmd rmrf "$unpack_dir/"*
        return 1
    }
    x_cmd_pkg:info "Unpack is done"

    ___x_cmd_pkg_carapace_bin_gen_shim || return 1
}
___x_cmd_pkg_carapace_bin_gen_shim(){
    ___x_cmd_pkg_shim_gen --mode app --code sh --bin_file  carapace                || return
    [ "$___X_CMD_PKG___META_OS" != "win" ] || {
        ___x_cmd_pkg_shim_gen --mode app --code bat  --bin_file carapace.exe       || return
    }
}

___x_cmd_pkg_carapace_bin_populate
