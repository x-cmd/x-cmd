# shellcheck shell=dash

# check the --version
java --version && javac --version >&2 || {
    pkg:error "fail to get version"
    return 1
}

# test_java_boot(){
#     local candidate_version="${JAVA_HOME#"${___X_CMD_PKG_POPULATE_PATH}/"*}"
#     local candidate="${candidate_version%/*}"
#     local version="${candidate_version#*/}"

#     if [ -n "$candidate" ] && [ -n "$version" ] && [ -n "$candidate_version" ];then
#         return 0
#     else
#         pkg:error "Test boot failed "
#         return 1
#     fi
# }

# test_java_boot
