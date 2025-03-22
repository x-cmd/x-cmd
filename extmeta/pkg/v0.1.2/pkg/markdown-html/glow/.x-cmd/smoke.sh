# shellcheck shell=dash

# check the --version
if ! glow --version ;then
    pkg:error "fail to get version"
    return 1
fi
