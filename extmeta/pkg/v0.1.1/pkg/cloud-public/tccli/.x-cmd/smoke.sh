# shellcheck shell=dash

if ! tccli --version 2>&1;then
    pkg:error "tccli  fail to get version"
    return 1
fi
