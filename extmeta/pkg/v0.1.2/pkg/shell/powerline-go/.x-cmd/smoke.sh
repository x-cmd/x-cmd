
# shellcheck shell=dash

if ! powerline-go --help 2>&1;then
    pkg:error "fail to get help"
    return 1
fi

