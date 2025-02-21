
# shellcheck shell=dash

if ! slick --help 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

