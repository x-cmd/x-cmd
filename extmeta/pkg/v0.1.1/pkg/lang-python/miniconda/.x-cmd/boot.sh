# shellcheck shell=dash

___x_cmd_path_chain_which_ "$HOME/.local/bin" || ___x_cmd_path_down_or_push "$HOME/.local/bin"
if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
    ___x_cmd_path_up_or_unshift "$___X_CMD_PKG___META_TGT/Scripts"
else
    ___x_cmd_path_up_or_unshift "$___X_CMD_PKG___META_TGT/bin"
fi
