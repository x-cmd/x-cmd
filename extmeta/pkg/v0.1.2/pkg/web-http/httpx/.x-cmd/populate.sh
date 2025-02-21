# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/pip-populate.sh"

___x_cmd_pkg___pip_populate_install_dep(){
    local bin_dir="$1"

    local x_=
    if x pkg websrc pip_ 2>/dev/null || true; then
        "$___X_CMD_PKG___META_TGT/$bin_dir/pip" install \
            --require-virtualenv                        \
            'httpx[socks]' 'httpx[cli]'                 \
            -i "$x_"
    fi

}

___x_cmd_pkg___pip_populate httpx
