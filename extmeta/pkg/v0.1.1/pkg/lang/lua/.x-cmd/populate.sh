# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_lua_gen_pkgconfig(){
    local lua_pkgconfig="$___X_CMD_PKG___META_TGT/lib/pkgconfig/"
    command sed 's|@XCMD_LUA_INSTALL_PATH@|'"${___X_CMD_PKG___META_TGT}"'|g' "$lua_pkgconfig/lua.pc" > "$lua_pkgconfig/lua.pc.bak"
    x mv "$lua_pkgconfig/lua.pc.bak" "$lua_pkgconfig/lua.pc"
}

___x_cmd_pkg_lua_path_generate_(){
    local version="${1:-5.4}"

    local sub="?/init.lua"
    local homelib_="$HOME/.luarocks/share/lua/$version"            # ... # For luarocks and library compatibility
    local xlua_="${___X_CMD_ROOT_MOD}/lua/lib/share"
    local ws_=""
    local lm_="./lua_modules/share/lua/$version"
    local local_="./?.lua;./?/init.lua;"

    ___x_cmd os name_
    case "$___X_CMD_OS_NAME_" in
        win)
            sub="?\init.lua"
            homelib_="$(cygpath -w "$homelib_")"
            xlua_="$(cygpath -w "$xlua_")"
            lm_=".\lua_modules\share\lua\\$version"
            local_=".\?.lua;.\?\init.lua;"

            homelib_="$homelib_\?.lua;$homelib_\\$sub;"
            xlua_="$xlua_\?.lua;$xlua_\\$sub;"
            [ -z "$LUA_PATH_WS" ] || ws_="$LUA_PATH_WS\?.lua;$LUA_PATH_WS\\$sub;"
            lm_="$lm_\?.lua;$lm_\\$sub;"
            ;;
        *)
            homelib_="$homelib_/?.lua;$homelib_/$sub;"
            xlua_="$xlua_/?.lua;$xlua_/$sub;"
            [ -z "$LUA_PATH_WS" ] || ws_="$LUA_PATH_WS/?.lua;$LUA_PATH_WS/$sub;"
            lm_="$lm_/?.lua;$lm_/$sub;"
            ;;
    esac


    x_="${local_}${lm_}${ws_}${homelib_}${xlua_};"     # ; in the ending to insert the default
}

___x_cmd_pkg_lua_cpath_generate_(){
    local version="${1:-5.4}"

    local usrlib="/usr/local/lib/lua/$version"
    local homelib_="$HOME/.luarocks/lib/lua/$version"
    local ws_=""
    local lm_="./lua_modules/lib/lua/$version"
    local local_="./?.$ext;"

    local ext=so
    ___x_cmd os name_
    case "$___X_CMD_OS_NAME_" in
        linux)
            ext=so
            usrlib="$usrlib/?.$ext;$usrlib/loadall.$ext;"
            homelib_="$homelib_/?.$ext;$homelib_/loadall.$ext;"
            [ -z "$LUA_PATH_WS" ] || ws_="$LUA_PATH_WS/?.$ext;$LUA_PATH_WS/loadall.$ext;"
            lm_="$lm_/?.$ext;$lm_/loadall.$ext;"
            ;;
        darwin)
            ext=dylib
            usrlib="$usrlib/?.so;$usrlib/?.$ext;$usrlib/loadall.so;$usrlib/loadall.$ext;"
            homelib_="$homelib_/?.so;$homelib_/?.$ext;$homelib_/loadall.so;$homelib_/loadall.$ext;"
            [ -z "$LUA_PATH_WS" ] || ws_="$LUA_PATH_WS/?.so;$LUA_PATH_WS/?.$ext;$LUA_PATH_WS/loadall.so;$LUA_PATH_WS/loadall.$ext;"
            lm_="$lm_/?.so;$lm_/?.$ext;$lm_/loadall.so;$lm_/loadall.$ext;"
            local_="./?.so;$local_"
            ;;
        win)
            ext=dll
            usrlib="$(cygpath -w "$usrlib")"
            homelib_="$(cygpath -w "$homelib_")"
            lm_=".\lua_modules\lib\lua\\$version"
            local_=".\?.$ext;"

            usrlib="$usrlib\?.$ext;$usrlib\loadall.$ext;"
            homelib_="$homelib_\?.$ext;$homelib_\loadall.$ext;"
            [ -z "$LUA_PATH_WS" ] || ws_="$LUA_PATH_WS\?.$ext;$LUA_PATH_WS\loadall.$ext;"
            lm_="$lm_\?.$ext;$lm_\loadall.$ext;"
            ;;
    esac

    x_="${local_}${lm_}${ws_}${homelib_}${usrlib}"          # No ; in the ending
}

___x_cmd_pkg_lua_gen_shim_bin(){
    local x_=; local lua_path=; local lua_cpath=
    x_=; ___x_cmd_pkg_lua_path_generate_  "$lua_version" || return 1
    lua_path="$x_"

    x_=; ___x_cmd_pkg_lua_cpath_generate_ "$lua_version" || return 1
    lua_cpath="$x_"

    local bin_suffix=
    ___x_cmd os name_
    [ "$___X_CMD_OS_NAME_" != "win" ] || bin_suffix=".exe"

    ___x_cmd_pkg_shim_gen                               \
        --mode app --code sh                            \
        --var "LUA_PATH=\${LUA_PATH:-$lua_path}"        \
        --var "LUA_CPATH=\${LUA_CPATH:-$lua_cpath}"     \
        --bin_dir bin --bin_file "lua${bin_suffix}" "luac${bin_suffix}"           || return
    {
        x cp "$___X_CMD_PKG___META_TGT/shim_bin/lua"  "$___X_CMD_PKG___META_TGT/shim_bin/lua${suffix}"
        x cp "$___X_CMD_PKG___META_TGT/shim_bin/luac" "$___X_CMD_PKG___META_TGT/shim_bin/luac${suffix}"
        x cp "$___X_CMD_PKG___META_TGT/shim_bin/lua"  "$___X_CMD_PKG___META_TGT/shim_bin/lua${lua_version}"
        x cp "$___X_CMD_PKG___META_TGT/shim_bin/luac" "$___X_CMD_PKG___META_TGT/shim_bin/luac${lua_version}"
    } || return 1

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen                               \
            --mode app --code bat                           \
            --var "LUA_PATH=\${LUA_PATH:-$lua_path}"        \
            --var "LUA_CPATH=\${LUA_CPATH:-$lua_cpath}"     \
            --bin_dir bin --bin_file "lua${bin_suffix}" "luac${bin_suffix}"           || return
        {
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/lua.bat"  "$___X_CMD_PKG___META_TGT/shim_bin/lua${suffix}.bat"
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/luac.bat" "$___X_CMD_PKG___META_TGT/shim_bin/luac${suffix}.bat"
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/lua.bat"  "$___X_CMD_PKG___META_TGT/shim_bin/lua${lua_version}.bat"
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/luac.bat" "$___X_CMD_PKG___META_TGT/shim_bin/luac${lua_version}.bat"
        } || return 1
    fi
}

___x_cmd_pkg_lua_gen_ln(){
    ___x_cmd_cmds_ln -s \
        "$___X_CMD_PKG___META_TGT/include/lua" \
        "$___X_CMD_PKG___META_TGT/include/lua${lua_version}" > /dev/null 2>&1
    ___x_cmd_cmds_ln -s \
        "$___X_CMD_PKG___META_TGT/include/lua" \
        "$___X_CMD_PKG___META_TGT/include/lua-${lua_version}" > /dev/null 2>&1
}

___x_cmd_pkg_lua_populate(){
    local lua_version=; local suffix=
    case "$___X_CMD_PKG___META_VERSION" in
        v5.1*) lua_version="5.1"; suffix="51" ;;
        *)     lua_version="5.4"; suffix="54" ;;
    esac

    ___x_cmd_pkg_lua_gen_pkgconfig || return
    ___x_cmd_pkg_lua_gen_shim_bin  || return
    ___x_cmd_pkg_lua_gen_ln        || return
}

___x_cmd_pkg_lua_populate
