# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open

# check the --version

if ! mvnd --version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi


# test_mvnd_boot(){
#     local candidate_version="${MVND_HOME#"${___X_CMD_PKG_POPULATE_PATH}/"*}"
#     local candidate="${candidate_version%/*}"
#     local version="${candidate_version#*/}"

#     if [ -n "$candidate" ] && [ -n "$version" ] && [ -n "$candidate_version" ];then
#         return 0
#     else
#         pkg:error "Test boot failed "
#         return 1
#     fi
# }

# test_mvnd_boot
