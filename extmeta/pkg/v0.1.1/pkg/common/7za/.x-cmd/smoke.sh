# shellcheck shell=dash

# check the --version

if ! 7za -h 2>&1 ;then
    pkg:error "fail to get version"
    return 1
fi | head -n 5
