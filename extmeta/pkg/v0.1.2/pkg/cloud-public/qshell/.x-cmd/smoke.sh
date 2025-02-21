# shellcheck shell=dash

# check the --version
if ! qshell --version >&2 ;then
    pkg:error "qshell  fail to get version"
    return 1
fi
