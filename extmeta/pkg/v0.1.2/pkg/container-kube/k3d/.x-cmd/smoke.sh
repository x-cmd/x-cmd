# shellcheck shell=dash

if ! k3d --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi
