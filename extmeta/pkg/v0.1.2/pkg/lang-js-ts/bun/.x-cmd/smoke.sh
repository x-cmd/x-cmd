# shellcheck shell=dash

# check the --version
if ! bun --version >&2;then
    pkg:error "fail to get version"
    return 1
fi
# return 1

if ! bun x cowsay 'hello x-cmd!' >&2;then
    pkg:error "Fail: bun x cowsay"
    return 1
fi