# shellcheck shell=dash

if ! echo "y" | hcloud version >&2 ;then
    pkg:error "koocli  fail to get version"
    return 1
fi
