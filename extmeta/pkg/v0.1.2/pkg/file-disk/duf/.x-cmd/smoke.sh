# shellcheck shell=dash

# check the --version
if ! duf --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi
