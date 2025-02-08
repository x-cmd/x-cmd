# shellcheck shell=dash

if ! lua -v >&2;then
    pkg:error "fail to get version"
    return 1
fi