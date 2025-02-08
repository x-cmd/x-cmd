# shellcheck shell=dash
x log init x_cmd_pkg
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh" ||  return 1


___x_cmd_pkg_python_populate(){
    # shellcheck disable=SC2034
    local PYTHONHOME="";
    # shellcheck disable=SC2034
    local PYTHONPATH="";

    local download_file_ext=; local tree=
    ___x_cmd_pkg___attr "$___X_CMD_PKG___META_NAME" "$___X_CMD_PKG___META_VERSION" "$___X_CMD_PKG___META_OS/$___X_CMD_PKG___META_ARCH" "tree,download_file_ext"
    local archive_path="$___X_CMD_PKG_DOWNLOAD_PATH/$___X_CMD_PKG___META_NAME/${___X_CMD_PKG___META_VERSION}.${tree}.$download_file_ext"
    local populate_path="$___X_CMD_PKG___META_TGT"

    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then

        local tmp_populate_path="$populate_path"
        archive_path="$(cygpath -w "${archive_path}")"
        tmp_populate_path="$(cygpath -w "${populate_path}")"
        x:debug "Start-Process -Wait -FilePath \"${archive_path}\"  -ArgumentList \"/S /D=${tmp_populate_path}\""
        x pwsh "Start-Process -Wait -FilePath \"${archive_path}\"  -ArgumentList \"/S /D=${tmp_populate_path}\"" || {
            x_cmd_pkg:error "Fail to use powershell => Start-Process -Wait -FilePath \"${archive_path}\"  -ArgumentList \"/S /D=${tmp_populate_path}\" "
            return 1
        }

        "$populate_path/python.exe" -m ensurepip || {
            x_cmd_pkg:error "ensurepip failed"
            return 1
        }
    else
        #TODO: REMOVE when v0.0.3 pkg released (mv to cp in xbash/pkg )
        [ -f "$archive_path" ] || archive_path="$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}.${tree}.$download_file_ext"

        command chmod +x "${archive_path}" || {
            x_cmd_pkg:error "Fail to chmod +x ${archive_path}"
            return 1
        }

        "${archive_path}" -b -u -p "${populate_path}" || {
            x_cmd_pkg:error "Fail to unpack python $___X_CMD_PKG___META_VERSION."
            return 1
        }
    fi


    x_cmd_pkg:info "Finish python $___X_CMD_PKG___META_VERSION unpack."
}

___x_cmd_pkg_python_shim(){
    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat  --bin_file python.exe Scripts/pip.exe Scripts/pip3.exe Scripts/conda.exe || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh   --bin_file python.exe Scripts/pip.exe Scripts/pip3.exe Scripts/conda.exe || return
        {
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/python" "$___X_CMD_PKG___META_TGT/shim_bin/python3"
            x cp "$___X_CMD_PKG___META_TGT/shim_bin/python.bat" "$___X_CMD_PKG___META_TGT/shim_bin/python3.bat"
            ! [ -d "$___X_CMD_PKG___META_TGT/adaptive_shim_bin" ] || {
                x cp "$___X_CMD_PKG___META_TGT/adaptive_shim_bin/python" "$___X_CMD_PKG___META_TGT/adaptive_shim_bin/python3"
                x cp "$___X_CMD_PKG___META_TGT/adaptive_shim_bin/python.bat" "$___X_CMD_PKG___META_TGT/adaptive_shim_bin/python3.bat"
            }
        }
    else
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --bin_dir bin --bin_file python pip pip3 python3 conda || return
    fi
}

___x_cmd_pkg_python_populate || return
___x_cmd_pkg_python_shim
