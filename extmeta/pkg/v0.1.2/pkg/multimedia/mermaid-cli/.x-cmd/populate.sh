# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/npm-populate.sh"

___x_cmd_pkg___npm_populate_install(){
    local pkg_install_name="@mermaid-js/mermaid-cli"

    local x_=
    if x pkg websrc npm_ 2>/dev/null || true; then
        npm install                                          \
            --prefix "$___X_CMD_PKG___META_TGT"              \
            "$pkg_install_name@$___X_CMD_PKG___META_VERSION" \
            --registry="$x_"                                 \
        || return 1
    fi
}

___x_cmd_pkg___npm_populate mmdc browsers extract-zip js-yaml
