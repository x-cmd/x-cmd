# shellcheck shell=dash

if ! gitleaks version ;then
    pkg:error "fail to get version"
    return 1
fi
