#! /bin/sh

. "${___X_CMD_ROOT}/v/${___X_CMD_VERSION}/X"

___X_CMD_DAEMON_PROC_ID="$(x date vlid).$$"
xrc daemon
x mkdirp "$___X_CMD_DAEMON_LOG_FILEPATH"

if [ -e "$___X_CMD_DAEMON_STDIN_FIFO" ]; then
    trap "rm \"$___X_CMD_DAEMON_STDIN_FIFO\"" EXIT
fi

# trap '___x_cmd_daemon_proc_end 130 >>"${___X_CMD_DAEMON_PROC_FILEPATH}/$___X_CMD_DAEMON_PROC_ID"' INT
# trap '___x_cmd_daemon_proc_end 131 >>"${___X_CMD_DAEMON_PROC_FILEPATH}/$___X_CMD_DAEMON_PROC_ID"' QUIT
# trap '___x_cmd_daemon_proc_end 137 >>"${___X_CMD_DAEMON_PROC_FILEPATH}/$___X_CMD_DAEMON_PROC_ID"' KILL
# trap '___x_cmd_daemon_proc_end 143 >>"${___X_CMD_DAEMON_PROC_FILEPATH}/$___X_CMD_DAEMON_PROC_ID"' TERM
# trap '___x_cmd_daemon_proc_end 138 >>"${___X_CMD_DAEMON_PROC_FILEPATH}/$___X_CMD_DAEMON_PROC_ID"' USR1

# TODO: Add retry loop for this.
___x_cmd_daemon_proc_run "$___X_CMD_DAEMON_PROC_ID" "$@" >> "${___X_CMD_DAEMON_LOG_FILEPATH}/${___X_CMD_DAEMON_PROC_ID}"
