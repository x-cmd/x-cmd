# shellcheck    shell=dash

if [ "$___X_CMD_PKG___META_OS" = "win" ] ; then
    x mv  "$___X_CMD_PKG___META_TGT/${___X_CMD_PKG___META_VERSION}"* "$___X_CMD_PKG___META_TGT/tea.exe"
else
    x mv "$___X_CMD_PKG___META_TGT/tea"* "$___X_CMD_PKG___META_TGT/tea"
fi
