# shellcheck shell=dash

# check the --version
if ! gcloud version >&2 ;then
    pkg:error "gcloud  fail to get version"
    return 1
fi
