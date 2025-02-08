# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_node_populate(){
    # Ensure npm root after install
    # x mkdirp \
    #     "$___X_CMD_PKG___META_TGT/.npm/lib" \
    #     "$___X_CMD_PKG___META_TGT/.npm/bin"

    x mkdirp "$HOME/.npm/lib" "$HOME/.npm/bin"

    if [ -d "${___X_CMD_PKG___META_TGT}/lib/node_modules/npm" ]; then
        printf "%s\n" "prefix = \"${HOME}/.npm\""   > "${___X_CMD_PKG___META_TGT}/lib/node_modules/npm/npmrc"
    elif [ -d "${___X_CMD_PKG___META_TGT}/node_modules/npm" ]; then
        printf "%s\n" "prefix = \"${HOME}/.npm\""   > "${___X_CMD_PKG___META_TGT}/node_modules/npm/npmrc"
    fi

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen                                       \
            --mode adaptive --code bat                              \
            --bin_dir ""    --bin_file corepack.cmd install_tools.bat nodevars.bat npm.cmd npx.cmd node.exe \
        || return
        ___x_cmd_pkg_shim_gen                                       \
            --mode adaptive --code sh                               \
            --bin_dir ""    --bin_file corepack npm npx node.exe                                            \
        || return
    else
        ___x_cmd_pkg_shim_gen                                       \
            --mode adaptive --code sh                               \
            --bin_dir "bin" --bin_file corepack npm npx node                                                \
        || return
    fi
}

___x_cmd_pkg_node_populate


