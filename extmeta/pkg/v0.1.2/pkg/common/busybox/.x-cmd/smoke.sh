# shellcheck shell=dash

# check the --version
if ! busybox --help ;then
    pkg:error "fail to get version"
    return 1
fi
