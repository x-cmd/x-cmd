# shellcheck shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh"

___x_cmd_pkg_vhs_populate(){

    local binpath=; local line=; local dep_name=; local dep_version=; local dep_binpath=
    while read -r line; do
        [ -n "$line" ] || continue
        dep_name="${line%%=*}"
        dep_version="${line#*=}"
        x_treename=; ___x_cmd_pkg_treename_ "$dep_name" "$dep_version" "${___X_CMD_PKG___META_OS}/${___X_CMD_PKG___META_ARCH}" || return
        dep_binpath="$(___x_cmd_pkg___list "$dep_name" "$dep_version" "${___X_CMD_PKG___META_OS}/${___X_CMD_PKG___META_ARCH}" path.bin)" || return
        [ -n "$dep_binpath" ] || continue
        dep_binpath="$___X_CMD_PKG_ROOT_SPHERE/$___X_CMD_PKG___META_SPHERE_NAME/$x_treename/$dep_name/$dep_version/$dep_binpath"
        binpath="${binpath}:${dep_binpath}"
    done <<A
$( ___x_cmd_pkg___list "${___X_CMD_PKG___META_NAME}" "${___X_CMD_PKG___META_VERSION}" "${___X_CMD_PKG___META_OS}/${___X_CMD_PKG___META_ARCH}" dep )
A

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen               \
            --mode app                      \
            --code bat                      \
            --var "PATH=${binpath}:\$PATH"  \
            --bin_dir "bin"                 \
            --bin_file "vhs.exe"            \
        || return
    fi

    ___x_cmd_pkg_shim_gen               \
        --mode app                      \
        --code sh                       \
        --var "PATH=${binpath}:\$PATH"  \
        --bin_dir "bin"                 \
        --bin_file "vhs"                \
    || return
}

___x_cmd_pkg_vhs_populate
