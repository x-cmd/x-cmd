# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"


___x_cmd_pkg_zig_populate(){
    x mkdirp "$___X_CMD_PKG___META_TGT/bin"

    ___x_cmd_pkg_shim_gen --mode adaptive --code sh --bin_dir "" --bin_file zig || return
    [ "$___X_CMD_PKG___META_OS" != "win" ] || {
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat --bin_dir "" --bin_file zig.exe || return
    }

    x cp "$___X_CMD_PKG___META_TGT/shim_bin"/* "$___X_CMD_PKG___META_TGT/bin/"
}

___x_cmd_pkg_zig_populate
