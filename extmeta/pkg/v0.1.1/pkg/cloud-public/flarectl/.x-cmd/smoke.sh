# shellcheck shell=dash

# check the --version
if ! flarectl --version >&2 ;then
    pkg:error "flarectl  fail to get version"
    return 1
fi
