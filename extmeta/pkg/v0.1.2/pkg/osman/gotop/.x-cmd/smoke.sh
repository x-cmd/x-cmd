# shellcheck shell=dash

if ! gotop --version ;then
    pkg:error "fail to get version"
    return 1
fi
