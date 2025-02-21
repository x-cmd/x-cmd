# shellcheck    shell=dash

. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/pip-populate.sh"

if [ "$___X_CMD_PKG___META_OS" = "win" ] ; then
    ___x_cmd_pkg___pip_populate qingcloud.cmd
else
    ___x_cmd_pkg___pip_populate qingcloud
fi
