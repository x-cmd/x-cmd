# shellcheck shell=dash

if ! CodeFormat check -w . -d 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

