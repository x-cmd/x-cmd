# shellcheck shell=dash

if ! hx --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi
hx --health 2>&1

