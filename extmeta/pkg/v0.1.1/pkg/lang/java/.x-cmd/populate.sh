# shellcheck shell=dash

___x_cmd_pkg_java_populate(){
    [ "$___X_CMD_PKG___META_OS" = "darwin" ] || {
        pkg:debug "Skipping java populate for $___X_CMD_PKG___META_OS"
        return 0
    }

    case "$___X_CMD_PKG___META_VERSION" in
        *-open|*-sapmchn|*-trava|*-oracle|*-grl|*-gln|*-amzn|*-nik|*-tem|*-sem)
            pkg:info "Java populate. Copying $___X_CMD_PKG___META_TGT/Contents/Home/* to $___X_CMD_PKG___META_TGT/"
            x mv "$___X_CMD_PKG___META_TGT/Contents/Home/"* "$___X_CMD_PKG___META_TGT/"
            x rmrf "$___X_CMD_PKG___META_TGT/Contents"
            ;;
    esac

}

___x_cmd_pkg_java_populate || return


. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/gen_shim_file.sh" || return

___x_cmd_pkg_java_shim(){
    if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
        ___x_cmd_pkg_shim_gen --mode adaptive --code bat --var "JAVAHOME=$___X_CMD_PKG___META_TGT" --bin_dir bin --bin_file java.exe javac.exe || return
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --var "JAVAHOME=$___X_CMD_PKG___META_TGT" --bin_dir bin --bin_file java.exe javac.exe || return
    else
        ___x_cmd_pkg_shim_gen --mode adaptive --code sh  --var "JAVAHOME=$___X_CMD_PKG___META_TGT"  --bin_dir bin --bin_file java javac || return
    fi

}

___x_cmd_pkg_java_shim


