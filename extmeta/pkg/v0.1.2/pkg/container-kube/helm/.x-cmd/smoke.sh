# shellcheck shell=dash

if ! helm version ;then
    pkg:error "fail to get version"
    return 1
fi
