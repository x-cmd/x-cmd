# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_bun_populate(){
    # Ensure deno install root and deno bin after install
    # x mkdirp \
    #     "$___X_CMD_PKG___META_TGT/.bun/bin"
    x mkdirp "$HOME/.bun/bin"
    # Create manually bunx after install
    local bin_suffix=
    [ "$___X_CMD_PKG___META_OS" != "win" ] || bin_suffix=.exe
    command ln -s \
        "$___X_CMD_PKG___META_TGT/bin/bun${bin_suffix}" \
        "$___X_CMD_PKG___META_TGT/bin/bunx${bin_suffix}" > /dev/null 2>&1 || return 0

    local source="$___X_CMD_PKG___META_TGT/bin"
    local target="$___X_CMD_PKG___META_TGT/shim_bin"

    x mkdirp "$target"

    x_cmd_pkg:info --source "$source" --shim_bin "$target" "shim gen sh code"
        # --var "BUN_INSTALL=$___X_CMD_PKG___META_TGT/.bun"               \
    ___x_cmd_pkg_shim_gen                                               \
        --mode adaptive --code sh                                       \
        --bin_dir bin --bin_file "bun${bin_suffix}" "bunx${bin_suffix}" \
    || return

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        x_cmd_pkg:info --source "$source" --shim_bin "$target" "shim gen bat code"
            # --var "BUN_INSTALL=$___X_CMD_PKG___META_TGT/.bun"               \
        ___x_cmd_pkg_shim_gen                                               \
            --mode adaptive --code bat                                      \
            --bin_dir bin --bin_file "bun${bin_suffix}" "bunx${bin_suffix}" \
        || return
    fi
}

___x_cmd_pkg_bun_populate

