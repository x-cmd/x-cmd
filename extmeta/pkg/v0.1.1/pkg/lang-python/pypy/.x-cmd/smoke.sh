# shellcheck shell=dash

# check the --version
python --version && pip --version >&2 || {
    pkg:error "fail to get version"
    return 1
}
