#shellcheck shell=dash

. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_go_populate(){
    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat --bin_dir bin --bin_file go.exe gofmt.exe || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --bin_dir bin --bin_file go.exe gofmt.exe || return
    else
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --bin_dir bin --bin_file go gofmt || return
    fi

}

___x_cmd_pkg_go_populate


