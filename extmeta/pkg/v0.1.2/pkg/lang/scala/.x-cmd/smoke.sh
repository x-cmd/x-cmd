# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open

# check the --version

if ! scala --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi
