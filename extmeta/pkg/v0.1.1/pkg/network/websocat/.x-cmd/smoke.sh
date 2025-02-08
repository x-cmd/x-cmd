# shellcheck shell=dash

if ! (websocat --help | head -n 2) 2>&1 ;then
    pkg:error "fail to get version"
    return 1
fi
