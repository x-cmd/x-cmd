
# shellcheck shell=dash

if ! invoice help 2>&1;then
    pkg:error "fail to get help"
    return 1
fi

