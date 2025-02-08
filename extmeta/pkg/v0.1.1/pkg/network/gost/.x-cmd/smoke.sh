# shellcheck shell=dash

if ! gost --help ;then
    pkg:error "fail to get version"
    return 1
fi
