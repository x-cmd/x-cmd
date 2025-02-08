# shellcheck shell=dash

if ! az version 2>&1;then
    pkg:error "az  fail to get version"
    return 1
fi
