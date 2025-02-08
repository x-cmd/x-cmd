# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/pip-populate.sh"
___x_cmd_pkg___pip_populate_install(){
    local pkg_install_name="$___X_CMD_PKG___META_NAME"
    local bin_dir="$1"

    local x_=
    if x pkg websrc pip_ 2>/dev/null || true; then
        "$___X_CMD_PKG___META_TGT/$bin_dir/pip" install \
            --require-virtualenv                                  \
            "$pkg_install_name==${___X_CMD_PKG___META_VERSION#v}" \
            "opencv-contrib-python"                               \
            -i "$x_"

    fi
}
___x_cmd_pkg___pip_populate --python_version v3.8.0+23.11.0-2 video-to-ascii
