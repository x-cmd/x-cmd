# shellcheck shell=dash

# check the --version
if ! doctl version >&2 ;then
    pkg:error "doctl  fail to get version"
    return 1
fi
