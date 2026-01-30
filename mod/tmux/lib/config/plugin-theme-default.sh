# shellcheck shell=dash

# Section: color variable
___X_CMD_TMUX_PRIMARY_COLOR=${___X_CMD_THEME_COLOR_KEY:-"green"}
# Default minor： black -> gray
___X_CMD_TMUX_MINOR_0=${___X_CMD_TMUX_MINOR_0:-"colour232"}
___X_CMD_TMUX_MINOR_1=${___X_CMD_TMUX_MINOR_1:-"colour233"}
___X_CMD_TMUX_MINOR_2=${___X_CMD_TMUX_MINOR_2:-"colour234"}
___X_CMD_TMUX_MINOR_3=${___X_CMD_TMUX_MINOR_3:-"colour235"}
___X_CMD_TMUX_MINOR_4=${___X_CMD_TMUX_MINOR_4:-"colour236"}
___X_CMD_TMUX_MINOR_5=${___X_CMD_TMUX_MINOR_5:-"colour237"}
___X_CMD_TMUX_MINOR_6=${___X_CMD_TMUX_MINOR_6:-"colour238"}
___X_CMD_TMUX_MINOR_7=${___X_CMD_TMUX_MINOR_7:-"colour239"}
___X_CMD_TMUX_MINOR_8=${___X_CMD_TMUX_MINOR_8:-"colour240"}
___X_CMD_TMUX_MINOR_9=${___X_CMD_TMUX_MINOR_9:-"colour241"}
___X_CMD_TMUX_MINOR_10=${___X_CMD_TMUX_MINOR_10:-"colour242"}
___X_CMD_TMUX_MINOR_11=${___X_CMD_TMUX_MINOR_11:-"colour243"}

___X_CMD_TMUX_FG_COLOR=${___X_CMD_TMUX_FG_COLOR:-"$___X_CMD_TMUX_MINOR_9"}
___X_CMD_TMUX_BG_COLOR=${___X_CMD_TMUX_BG_COLOR:-"$___X_CMD_TMUX_MINOR_3"}
# EndSection

# Section: powerline icon - need nerd-fonts support
# ___X_CMD_TMUX_RIGHT_ARROW_ICON=''
# ___X_CMD_TMUX_LEFT_ARROW_ICON=''
# ___X_CMD_TMUX_RIGHT_HOLLOW_ARROW_ICON=''
# ___X_CMD_TMUX_LEFT_HOLLOW_ARROW_ICON=''

# ___X_CMD_TMUX_SESSION_ICON='  '
# ___X_CMD_TMUX_UPLOAD_SPEED_ICON=''
# ___X_CMD_TMUX_DOWNLOAD_SPEED_ICON=''
# ___X_CMD_TMUX_TIME_ICON='  '
# ___X_CMD_TMUX_FOLDER_ICON=''
# ___X_CMD_TMUX_USER_ICON=' '
# EndSection

# Section: pane border style
$___X_CMD_TMUX_BIN set -g     pane-border-style         "fg=$___X_CMD_TMUX_MINOR_6"
$___X_CMD_TMUX_BIN set -g     pane-active-border-style  "fg=$___X_CMD_TMUX_PRIMARY_COLOR"
# EndSection

# Section: status options
$___X_CMD_TMUX_BIN set        status on
$___X_CMD_TMUX_BIN set        status-interval 10
# EndSection

# Section: status bar style
# ----- base ------
$___X_CMD_TMUX_BIN set -g     status-style              "fg=$___X_CMD_TMUX_FG_COLOR,bg=$___X_CMD_TMUX_BG_COLOR"

# ----- left ------
# $___X_CMD_TMUX_BIN set -g     status-left "#($___X_CMD_TMUX_BIN show -v mouse)  "
# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%H:%M)  "
# $___X_CMD_TMUX_BIN set -g     status-left "#(date +%T)  "

# TODO: el
# x ___X_CMD_TMUX_STATUS_LEFT=join \
#     "#[" "fg=$___X_CMD_TMUX_MINOR_4"        , "bg=$___X_CMD_TMUX_PRIMARY_COLOR" "]"     "${___X_CMD_TMUX_SESSION_ICON}"         "[#S]" \
#     "#[" "fg=$___X_CMD_TMUX_PRIMARY_COLOR"  , "bg=$___X_CMD_TMUX_BG_COLOR]"             "${___X_CMD_TMUX_RIGHT_ARROW_ICON}"

___X_CMD_TMUX_STATUS_LEFT="#[fg=$___X_CMD_TMUX_MINOR_4,bg=$___X_CMD_TMUX_PRIMARY_COLOR]${___X_CMD_TMUX_SESSION_ICON}[#S]"
___X_CMD_TMUX_STATUS_LEFT="$___X_CMD_TMUX_STATUS_LEFT#[fg=$___X_CMD_TMUX_PRIMARY_COLOR,bg=$___X_CMD_TMUX_BG_COLOR]${___X_CMD_TMUX_RIGHT_ARROW_ICON}"
$___X_CMD_TMUX_BIN set -g     status-left               "$___X_CMD_TMUX_STATUS_LEFT"
$___X_CMD_TMUX_BIN set -g     status-left-length        150

# ----- right ------
___x_cmd_os_name_
if [ -n "$___X_CMD_TMUX_LEFT_ARROW_ICON" ]; then

    # TODO: el
    # x ___X_CMD_TMUX_STATUS_RIGHT=join \
    #     "#[" "fg=$___X_CMD_TMUX_PRIMARY_COLOR"  , "bg=$___X_CMD_TMUX_BG_COLOR"      "]"     "${___X_CMD_TMUX_LEFT_ARROW_ICON}" \
    #     "#[" "fg=$___X_CMD_TMUX_MINOR_4"        , "bg=$___X_CMD_TMUX_PRIMARY_COLOR" "]"     "#(. $___X_CMD_ROOT_MOD/os/lib/loadavg; ___X_CMD_OS_NAME_=$___X_CMD_OS_NAME_ ___x_cmd_os_loadavg___get_from_osname)" \
    #     "| ${___X_CMD_TMUX_USER_ICON}"  "#{host}"  ' ' "${___X_CMD_TMUX_LEFT_HOLLOW_ARROW_ICON}" "${___X_CMD_TMUX_TIME_ICON}"  "#(date +%H:%M)"

    ___X_CMD_TMUX_STATUS_RIGHT="#[fg=$___X_CMD_TMUX_PRIMARY_COLOR,bg=$___X_CMD_TMUX_BG_COLOR]${___X_CMD_TMUX_LEFT_ARROW_ICON}"
    ___X_CMD_TMUX_STATUS_RIGHT="${___X_CMD_TMUX_STATUS_RIGHT}#[fg=$___X_CMD_TMUX_MINOR_4,bg=$___X_CMD_TMUX_PRIMARY_COLOR]#(. $___X_CMD_ROOT_MOD/os/lib/loadavg; ___X_CMD_OS_NAME_=$___X_CMD_OS_NAME_ ___x_cmd_os_loadavg___get_from_osname) | ${___X_CMD_TMUX_USER_ICON}#{host}"
    ___X_CMD_TMUX_STATUS_RIGHT="$___X_CMD_TMUX_STATUS_RIGHT ${___X_CMD_TMUX_LEFT_HOLLOW_ARROW_ICON}${___X_CMD_TMUX_TIME_ICON} #(date +%H:%M)"
else
    ___X_CMD_TMUX_STATUS_RIGHT="#[fg=$___X_CMD_TMUX_MINOR_4,bg=$___X_CMD_TMUX_PRIMARY_COLOR] #(. $___X_CMD_ROOT_MOD/os/lib/loadavg; ___X_CMD_OS_NAME_=$___X_CMD_OS_NAME_ ___x_cmd_os_loadavg___get_from_osname) | 🌐 #{host} ⏰ #(date +%H:%M) "
fi
$___X_CMD_TMUX_BIN set -g     status-right              "$___X_CMD_TMUX_STATUS_RIGHT"
$___X_CMD_TMUX_BIN set -g     status-right-length        150
# EndSection

# Section: windows style
$___X_CMD_TMUX_BIN setw -g    status-justify centre
$___X_CMD_TMUX_BIN setw -g    window-status-separator   ''
$___X_CMD_TMUX_BIN setw -g    window-status-format      " #I:#W "

if [ -n "$___X_CMD_TMUX_RIGHT_ARROW_ICON" ]; then

    # TODO: el
    # x ___X_CMD_TMUX_WINDOW_STATUS_CURRENT=join  \
        # "#["    "fg=$___X_CMD_TMUX_BG_COLOR"        ,   "bg=$___X_CMD_TMUX_MINOR_5"         "]"     "$___X_CMD_TMUX_RIGHT_ARROW_ICON" \
        # "#["    "fg=${___X_CMD_TMUX_PRIMARY_COLOR}" ,   "bg=${___X_CMD_TMUX_MINOR_5},bold"  "]"     "#I:#W#{?window_zoomed_flag,🔍,}" \
        # "#["    "fg=$___X_CMD_TMUX_MINOR_5"         ,   "bg=$___X_CMD_TMUX_BG_COLOR,nobold" "]"     "$___X_CMD_TMUX_RIGHT_ARROW_ICON"

    ___X_CMD_TMUX_WINDOW_STATUS_CURRENT="#[fg=$___X_CMD_TMUX_BG_COLOR,bg=$___X_CMD_TMUX_MINOR_5]$___X_CMD_TMUX_RIGHT_ARROW_ICON"
    ___X_CMD_TMUX_WINDOW_STATUS_CURRENT="$___X_CMD_TMUX_WINDOW_STATUS_CURRENT#[fg=${___X_CMD_TMUX_PRIMARY_COLOR},bg=${___X_CMD_TMUX_MINOR_5},bold]#I:#W#{?window_zoomed_flag,🔍,}"
    ___X_CMD_TMUX_WINDOW_STATUS_CURRENT="$___X_CMD_TMUX_WINDOW_STATUS_CURRENT#[fg=$___X_CMD_TMUX_MINOR_5,bg=$___X_CMD_TMUX_BG_COLOR,nobold]$___X_CMD_TMUX_RIGHT_ARROW_ICON"
else

    # TODO: el
    # x ___X_CMD_TMUX_WINDOW_STATUS_CURRENT=join  \
        # "#["    "fg=${___X_CMD_TMUX_PRIMARY_COLOR}" ,   "bg=${___X_CMD_TMUX_MINOR_5},bold" "]" " #I:#W " "#{?window_zoomed_flag,🔍,}"

    ___X_CMD_TMUX_WINDOW_STATUS_CURRENT="#[fg=${___X_CMD_TMUX_PRIMARY_COLOR},bg=${___X_CMD_TMUX_MINOR_5},bold] #I:#W #{?window_zoomed_flag,🔍,}"
fi
$___X_CMD_TMUX_BIN setw -g    window-status-current-format "$___X_CMD_TMUX_WINDOW_STATUS_CURRENT"
# EndSection

# Section: other style

# Message
$___X_CMD_TMUX_BIN setw -g    message-style                 "fg=$___X_CMD_TMUX_PRIMARY_COLOR,bg=$___X_CMD_TMUX_BG_COLOR"
# Command message
$___X_CMD_TMUX_BIN setw -g    message-command-style         "fg=$___X_CMD_TMUX_PRIMARY_COLOR,bg=$___X_CMD_TMUX_BG_COLOR"
# Copy mode highlight
$___X_CMD_TMUX_BIN setw -g    mode-style                    "fg=default,bg=$___X_CMD_TMUX_PRIMARY_COLOR"

# Pane number indicator
$___X_CMD_TMUX_BIN setw -g    display-panes-colour          "$___X_CMD_TMUX_MINOR_6"
$___X_CMD_TMUX_BIN setw -g    display-panes-active-colour   "$___X_CMD_TMUX_PRIMARY_COLOR"

# EndSection
