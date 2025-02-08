
# shellcheck shell=dash

if ! d2 --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

