#! /usr/bin/env bash

# ___x_cmd_pidofsubshell
# (
#     local ticks=1
#     while true; do
#         ticks="$((ticks+1))"
#         ___x_cmd_ui_update_lines_columns
#         printf "R:%s:%s:%s\n" "$ticks" "$COLUMNS" "$LINES"
#         sleep "${___X_CMD_UI_REFRESH_INTERVAL:-0.1}"
#     done
# ) &

# if [ -n "$ZSH_VERSION" ]; then
#     trap '___x_cmd_ui_region___run_clear; exit 130' INT  # FOR zsh trap
# else
#     trap ':; exit 130' INT   # FOR ___x_cmd_ui_getchar. Resolve bug in specific bash version. Refer issue:#I4Z4WH for more details
# fi
# while ___x_cmd_ui_getchar; do
#     printf "C:%s:%s\n" "${___X_CMD_UI_GETCHAR_TYPE}" "${___X_CMD_UI_GETCHAR_CHAR}" || break
# done

# kill -SIGINT "$PPID"            # Trap dd command in function ___x_cmd_ui_getchar for ash/dash. Issue:#I4Z4X1

[ -f "$___X_CMD_MOD_ROOT" ]

xrc:mod ui/lib/comp/tick_while_read

tick_while_read
