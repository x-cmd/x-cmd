# shellcheck shell=dash

$___X_CMD_TMUX_BIN    \
    set -g default-terminal "screen-256color" \; \
    if 'infocmp -x tmux-256color > /dev/null 2>&1' 'set -g default-terminal "tmux-256color"' \; \
    setw -g xterm-keys on       \; \
    set -s escape-time 10       \; \
    set -sg repeat-time 600     \; \
    set -s focus-events on      \; \
    set -q -g status-utf8 on    \; \
    setw -q -g utf8 on          \; \
    set -g history-limit 5000

    # escape-time: faster command sequences
    # repeat-time: increase repeat timeout
    # expect UTF-8 (tmux < 2.2)

# # set -g prefix2 C-SPACE                        # GNU-Screen compatible prefix
# bind C-a send-prefix -2


$___X_CMD_TMUX_BIN    \
    bind C-c new-session                    \;  \
    bind C-f command-prompt -p find-session 'switch-client -t %%' \; \
    bind BTab switch-client -l              \;  \
    bind '-' split-window -v                \;  \
    bind '|' split-window -h                \;  \
    bind \> swap-pane -D                    \;  \
    bind \< swap-pane -U                    \;  \
    bind Tab last-window                    \;  \
    set -g base-index 1                     \;  \
    setw -g pane-base-index 1               \;  \
    set -g mouse on                         \;  \
    bind M      set -g mouse                \;  \
    setw -g     automatic-rename    off     \;  \
    set -g      renumber-windows    on      \;  \
    set -g      set-titles          on      \;  \
    set -g      display-panes-time  800     \;  \
    set -g      display-time        1000    \;  \
    set -g      monitor-activity    on      \;  \
    set -g      visual-activity     off

# Problem
# tmux bind -n C-l send-keys C-l \; run 'sleep 0.2' \; clear-history #\
