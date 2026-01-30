# shellcheck shell=dash

# split:
#     - vertical
#     - horizontal
# new:
#     - window
#     - session
#     - pane
# kill:
#     - window
#     - session
#     - pane

___X_CMD_RUNMODE=5
. "${HOME}/.x-cmd.root/X"

while true; do
    ___x_cmd ui select idx "Command: " \
        "choose-tree        -- <PREFIX> + s"        \
        "vertical-split     -- <PREFIX> + \""       \
        "horizontal-split   -- <PREFIX> + %"        \
        "new-window         -- <PREFIX> + c"        \
        "kill-window        -- <PREFIX> + k"        \
        "kill-panel         -- <PREFIX> + x"        \
        "prev-window        -- <PREFIX> + n"        \
        "next-window        -- <PREFIX> + n"        \
        "run-cmd"

    case $? in
        130)            return 0
    esac

    case "$idx" in
        1)              ___x_cmd tmux choose-tree;           exit ;;
        2)              ___x_cmd tmux split-window -v;       exit ;;
        3)              ___x_cmd tmux split-window -h;       exit ;;
        4)              ___x_cmd tmux new-window;            exit ;;
        5)              ___x_cmd tmux kill-window;           exit ;;
        6)              ___x_cmd tmux kill-panel;            exit ;;
        7)              ___x_cmd tmux new-session;           exit ;;
        *)              exec /bin/bash ;;
    esac
done

