# shellcheck shell=dash

if ! tmux -V ;then
    pkg:error "fail to get version"
    return 1
fi
