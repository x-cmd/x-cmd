# shellcheck shell=dash

# check the subcmd
if ! ismc all >&2 ;then
    pkg:error "fail to Execute the subcmd"
    return 1
fi
