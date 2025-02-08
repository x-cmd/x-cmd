# shellcheck shell=dash
x log init x_cmd_pkg
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh" ||  return 1


___x_cmd_pkg_python_populate(){
    # shellcheck disable=SC2034
    local PYTHONHOME="";
    # shellcheck disable=SC2034
    local PYTHONPATH="";

    local populate_path="$___X_CMD_PKG___META_TGT"

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        "$populate_path/pypy.exe" -m ensurepip
        "$populate_path/pypy.exe" -m pip install --upgrade pip
        return 0
    else
        "$populate_path/bin/pypy" -m ensurepip
        "$populate_path/bin/pypy" -m pip install --upgrade pip
    fi


    x_cmd_pkg:info "Finish python $___X_CMD_PKG___META_VERSION unpack."
}

___x_cmd_pkg_python_shim(){
    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat  --bin_file python.exe pypy.exe        || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat  --bin_dir Scripts --bin_file pip.exe  || return

        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_file python.exe pypy.exe        || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_dir Scripts --bin_file pip.exe  || return
    else
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_dir bin --bin_file pypy python pip || return
    fi

}

___x_cmd_pkg_python_populate || return
___x_cmd_pkg_python_shim
