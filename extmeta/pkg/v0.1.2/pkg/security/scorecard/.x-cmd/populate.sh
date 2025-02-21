# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_scorecard_populate(){
    local tree=; local download_file_ext=; local _os=; local _arch=; local bin_suffix=;
    ___x_cmd_pkg___attr                   \
        "$___X_CMD_PKG___META_NAME" "$___X_CMD_PKG___META_VERSION"  \
        "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH"         \
        "download_file_ext,tree,_os,_arch,bin_suffix"                                         || return

    local ball="$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}.${tree}.${download_file_ext}"
    local unpack_dir="$___X_CMD_PKG___META_TGT"
    x_cmd_pkg:info  --ball "$___X_CMD_PKG_DOWNLOAD_PATH/$___X_CMD_PKG___META_NAME/${___X_CMD_PKG___META_VERSION}.${tree}.${download_file_ext}" --target_dir "$unpack_dir" "Unpacking"
    ___X_CMD_ZUZ_QUIET=1 ___x_cmd uzr "$ball" "$unpack_dir" || {
        ___x_cmd rmrf "$unpack_dir/"* "$ball"
        return 1
    }
    x_cmd_pkg:info "Unpack is done"
    ___x_cmd mv "$unpack_dir/scorecard-${_os}-${_arch}${bin_suffix}" "$unpack_dir/scorecard${bin_suffix}"
    ___x_cmd_cmds chmod +x "$unpack_dir/scorecard${bin_suffix}"

    ___x_cmd_pkg_scorecard_gen_shim || return 1
}
___x_cmd_pkg_scorecard_gen_shim(){
    ___x_cmd_pkg_shim_gen --mode app --code sh --bin_file  scorecard                || return
    [ "$___X_CMD_PKG___META_OS" != "win" ] || {
        ___x_cmd_pkg_shim_gen --mode app --code bat  --bin_file scorecard.exe       || return
    }
}

___x_cmd_pkg_scorecard_populate
