
# shellcheck shell=dash

if ! iamlive -h 2>&1;then
    pkg:error "fail to get help"
    return 1
fi

