# shellcheck shell=dash

# check the --version
___x_cmd env use java=v17.0.9-sem
if ! bpipe --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi
