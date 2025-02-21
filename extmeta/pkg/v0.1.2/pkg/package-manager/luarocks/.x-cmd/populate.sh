# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_luarocks_populate(){
    local ___X_CMD_PKG_RUNTIME_NODE_VERSION="v5.4.6"

    local x_treename=; local runtime_path=;
    ___x_cmd_pkg_treename_ lua "$___X_CMD_PKG_RUNTIME_NODE_VERSION" "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH" || return
    runtime_path="$___X_CMD_PKG_ROOT_SPHERE/$___X_CMD_PKG___META_SPHERE_NAME/$x_treename/lua/$___X_CMD_PKG_RUNTIME_NODE_VERSION"

    ___x_cmd_pkg_luarocks_prepare        || return
    ___x_cmd_pkg_luarocks_populate_      || return
    ___x_cmd_pkg_luarocks_gen_shim_bin   || return
}

___x_cmd_pkg_luarocks_prepare(){
    ___x_cmd_hascmd unzip || {
        # local dep_path="$___X_CMD_PKG___META_TGT/dep"
        # x mkdirp "$dep_path/cosmo" "$dep_path/bin"
        # x cosmo --install unzip "$dep_path/cosmo"
        # chmod +x "$dep_path/cosmo/unzip"
        # ___x_cmd_cmds_ln -s "$dep_path/cosmo/unzip" "$dep_path/bin/unzip" > /dev/null 2>&1
        x cosmo use unzip
    }
}

___x_cmd_pkg_luarocks_populate_(){
    case "$___X_CMD_PKG___META_OS" in
        win)    ___x_cmd_pkg_luarocks_populate_win  ;;
        *)      ___x_cmd_pkg_luarocks_populate_unix ;;
    esac
}

___x_cmd_pkg_luarocks_populate_unix(){
    local download_file_ext=; local tree=;local src_code_path=
    ___x_cmd_pkg___attr "$___X_CMD_PKG___META_NAME" "$___X_CMD_PKG___META_VERSION" "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH" "tree,download_file_ext"
    src_code_path="$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}.${tree}.$download_file_ext"

    {
        x uz "$src_code_path" "$___X_CMD_PKG___META_TGT/tmp/" >/dev/null
        x rmrf "$src_code_path"
    } || return
    x_cmd_pkg:info "Start compiling luarocks"
    x_cmd_pkg:debug "run cmd -> ./configure --prefix=$___X_CMD_PKG___META_TGT --with-lua=$runtime_path --with-lua-include=$runtime_path/include/lua/ && x cosmo make && DESTDIR=\"\" x cosmo make install"
    (
        # x path add_folder "$___X_CMD_PKG___META_TGT/dep/bin"
        x cd "$___X_CMD_PKG___META_TGT/tmp/luarocks-${___X_CMD_PKG___META_VERSION#v}"
        ./configure                                         \
            --prefix="$___X_CMD_PKG___META_TGT"             \
            --with-lua="$runtime_path"                      \
        && x cosmo make && DESTDIR="" x cosmo make install
    ) || {
        x_cmd_pkg:error "Compiling luarocks failed"
        return 1
    }
    x rmrf "$___X_CMD_PKG___META_TGT/tmp"  || return
    x mkdirp  "$___X_CMD_PKG___META_TGT/lib"
    x_cmd_pkg:info "Compile luarocks successfully"
    (
        x cd "$___X_CMD_PKG___META_TGT/"
        x rmrf "$___X_CMD_PKG___META_TGT/etc"
        "$___X_CMD_PKG___META_TGT/bin/luarocks" --lua-dir "$runtime_path" init
    ) || return 1
}

___x_cmd_pkg_luarocks_populate_win(){
    {
        x mkdirp "$___X_CMD_PKG___META_TGT/bin" "$___X_CMD_PKG___META_TGT/lib"
        x mv "$___X_CMD_PKG___META_TGT/luarocks.exe"        "$___X_CMD_PKG___META_TGT/bin/"
        x mv "$___X_CMD_PKG___META_TGT/luarocks-admin.exe"  "$___X_CMD_PKG___META_TGT/bin/"
    } || return

    # local tgt_cygpath=; tgt_cygpath="$(cygpath -w "$___X_CMD_PKG___META_TGT" | ___x_cmd_cmds sed 's/\\/\\\\/g;' )"
    (
        x cd "$___X_CMD_PKG___META_TGT/"
        "$___X_CMD_PKG___META_TGT/bin/luarocks.exe" --lua-dir "$(cygpath -w "$runtime_path")" init
        # {
        #     printf "\nrocks_trees = {\n   { name = \"user\", root = home .. \"/.luarocks\" };"
        #     printf "\n   { name = \"system\", root = \"%s\" };\n}\n" "$tgt_cygpath"
        # } >> "$___X_CMD_PKG___META_TGT/.luarocks/config-5.4.lua"
    ) || return 1
}

___x_cmd_pkg_luarocks_gen_shim_bin(){
    x mkdirp "$___X_CMD_PKG___META_TGT/shim_bin"

    local bin_suffix=
    local luarocks_config=; luarocks_config="$___X_CMD_PKG___META_TGT/.luarocks/config-5.4.lua"

    case "$___X_CMD_PKG___META_OS" in
        win)
            bin_suffix=.exe
            luarocks_config="$(cygpath -w "$___X_CMD_PKG___META_TGT/.luarocks/config-5.4.lua")"
                # --var "PATH=\$PATH:$___X_CMD_PKG___META_TGT/dep/bin"             \
            ___x_cmd_pkg_shim_gen                                                \
                --mode app --code bat                                            \
                --var "LUAROCKS_CONFIG=\${LUAROCKS_CONFIG:-$luarocks_config}"    \
                --bin_dir bin --bin_file "luarocks${bin_suffix}" "luarocks-admin${bin_suffix}"         || return
            ;;
    esac

        # --var "PATH=\$PATH:$___X_CMD_PKG___META_TGT/dep/bin"             \
    ___x_cmd_pkg_shim_gen                                                \
        --mode app --code sh                                             \
        --var "LUAROCKS_CONFIG=\${LUAROCKS_CONFIG:-$luarocks_config}"    \
        --bin_dir bin --bin_file "luarocks${bin_suffix}" "luarocks-admin${bin_suffix}"   || return
}

___x_cmd_pkg_luarocks_populate
