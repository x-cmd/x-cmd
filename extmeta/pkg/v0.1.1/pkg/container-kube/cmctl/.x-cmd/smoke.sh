
# shellcheck shell=dash
# get version return 1
if ! cmctl --help 2>&1;then
    pkg:error "fail to get help"
    return 1
fi

