# shellcheck shell=dash

$___X_CMD_TMUX_BIN \
    bind -r h select-pane -L  \; \
    bind -r j select-pane -D  \; \
    bind -r k select-pane -U  \; \
    bind -r l select-pane -R
