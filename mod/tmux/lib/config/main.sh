# shellcheck shell=dash

if ___x_cmd_hasbin tmux; then
    ___X_CMD_TMUX_BIN="tmux"
else
    ___x_cmd pkg xbin init tmux ___x_cmd___tmux_origin ___X_CMD_TMUX_BIN || return 1
fi

# ctrl + b + b ==> show popup
$___X_CMD_TMUX_BIN bind b     display-popup -E "${SHELL:-/bin/sh} $___X_CMD_ROOT_MOD/tmux/lib/config/popup.sh"

$___X_CMD_TMUX_BIN bind r     display-popup -E "${SHELL:-/bin/sh} $___X_CMD_ROOT_MOD/tmux/lib/config/ccal.sh"


# Plugin management
xrc:mod tmux/lib/config/plugin-util.sh

xrc:mod:lib     tmux \
                config/plugin-scroll.sh     \
                config/plugin-copy.sh       \
                config/plugin-control.sh    \
                config/plugin-theme-default.sh
