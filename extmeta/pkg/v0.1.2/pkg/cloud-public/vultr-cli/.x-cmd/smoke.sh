# shellcheck shell=dash

# check the --help
if ! vultr-cli --help >&2 ;then
    pkg:error "vultr-cli  fail to get help"
    return 1
fi
