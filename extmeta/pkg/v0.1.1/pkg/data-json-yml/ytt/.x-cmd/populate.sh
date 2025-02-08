# shellcheck    shell=dash
# TODO: remove
___x_cmd_pkg_populate_chmod_bin_tmp(){
    local bin_name="$1"
    local bin_suffix=
    x os name_
    [ "$___X_CMD_OS_NAME_" != "win" ] || bin_suffix=".exe"
    command chmod +x "$___X_CMD_PKG___META_TGT/bin/${bin_name}${bin_suffix}"
}

___x_cmd_pkg_populate_chmod_bin_tmp ytt
