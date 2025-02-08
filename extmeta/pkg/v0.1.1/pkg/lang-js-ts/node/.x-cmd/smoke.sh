# shellcheck shell=dash

# check the --version
node --version && npm --version && npx --version >&2 || {
    pkg:error "Fail to get version"
    return 1
}

npm install -g czg && czg --version >&2 || {
    pkg:error "Global npm package install failed"
    return 1
}

# test_node_boot(){
#     local test_NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX%/*}"
#     local candidate_version="${test_NPM_CONFIG_PREFIX#"${___X_CMD_PKG_POPULATE_PATH}/"*}"
#     local candidate="${candidate_version%/*}"
#     local version="${candidate_version#*/}"

#     if [ -n "$candidate" ] && [ -n "$version" ] && [ -n "$candidate_version" ];then
#         return 0
#     else
#         pkg:error "Test boot failed "
#         return 1
#     fi
# }

# test_node_boot
