
# shellcheck shell=dash

if ! hcl2json --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

