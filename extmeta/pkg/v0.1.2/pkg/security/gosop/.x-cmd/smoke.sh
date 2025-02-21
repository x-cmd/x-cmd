# shellcheck shell=dash

if ! gosop --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

