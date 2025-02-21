# shellcheck    shell=sh            disable=SC3043,2154,2034,2155
if [ "$___X_CMD_PKG___META_OS" = "win" ] ; then
    x mv  "$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}"* "$___X_CMD_PKG___META_TGT/act_runner.exe"
else
    x mv "$___X_CMD_PKG___META_TGT/act_runner"* "$___X_CMD_PKG___META_TGT/act_runner"
fi
