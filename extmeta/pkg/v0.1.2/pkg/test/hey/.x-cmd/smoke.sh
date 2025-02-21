
# shellcheck shell=dash

if ! hey -n 100 https://www.x-cmd.com 2>&1;then
    pkg:error "fail to requests"
    return 1
fi
