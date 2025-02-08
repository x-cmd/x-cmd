# shellcheck shell=dash

# check the --version

___x_cmd env use java=v21.0.2-open kotlin=v1.8.20

if ! kscript --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi
