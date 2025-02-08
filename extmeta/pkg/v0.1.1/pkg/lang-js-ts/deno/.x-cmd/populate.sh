# shellcheck shell=dash

# Using deno github source (not x-cmd repack). need move to bin/deno

# Ensure deno install root and deno bin after install
# x mkdirp \
#     "$___X_CMD_PKG___META_TGT/.deno/bin"
x mkdirp "$HOME/.deno/bin"


. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_deno_populate(){
    # if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
    #     ___x_cmd_pkg_shim_gen --mode adaptive --code bat --var "DENO_INSTALL_ROOT=$___X_CMD_PKG___META_TGT/.deno" --bin_dir bin --bin_file deno.exe || return
    #     ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --var "DENO_INSTALL_ROOT=$___X_CMD_PKG___META_TGT/.deno" --bin_dir bin --bin_file deno.exe || return
    # else
    #     ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --var "DENO_INSTALL_ROOT=$___X_CMD_PKG___META_TGT/.deno"  --bin_dir bin --bin_file deno || return
    # fi

    x mkdirp \
        "$___X_CMD_PKG___META_TGT/bin"

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        x mv "$___X_CMD_PKG___META_TGT/deno.exe" "$___X_CMD_PKG___META_TGT/bin/deno.exe"
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat  --bin_dir bin --bin_file deno.exe || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_dir bin --bin_file deno.exe || return
    else
        x mv "$___X_CMD_PKG___META_TGT/deno" "$___X_CMD_PKG___META_TGT/bin/deno"
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_dir bin --bin_file deno     || return
    fi

}

___x_cmd_pkg_deno_populate

