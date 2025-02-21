# shellcheck shell=dash

# check the --version
if ! ibmcloud --version >&2 ;then
    pkg:error "ibmcloud  fail to get version"
    return 1
fi
