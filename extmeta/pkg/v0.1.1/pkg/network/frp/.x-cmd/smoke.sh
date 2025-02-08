# shellcheck shell=dash

# check the --version
if ! frps --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi

if ! frpc --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi
