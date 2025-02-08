# shellcheck shell=dash

if ! qingcloud --version 2>&1;then
    pkg:error "qingcloud  fail to get version"
    return 1
fi
