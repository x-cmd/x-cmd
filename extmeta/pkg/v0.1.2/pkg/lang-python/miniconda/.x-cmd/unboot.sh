# shellcheck shell=dash

if [ "$___X_CMD_PKG___META_OS" = "win" ]; then
    if ___x_cmd_path_chain_which_ "$___X_CMD_PKG___META_TGT/Scripts";then
        ___x_cmd_path_rm "$___X_CMD_PKG___META_TGT/Scripts"
    fi
else
    if ___x_cmd_path_chain_which_ "$___X_CMD_PKG___META_TGT/bin";then
        ___x_cmd_path_rm "$___X_CMD_PKG___META_TGT/bin"
    fi
fi
# ___x_cmd_path_rm "$HOME/.local/bin"

