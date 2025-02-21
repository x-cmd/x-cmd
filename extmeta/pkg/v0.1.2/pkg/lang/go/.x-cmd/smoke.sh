# shellcheck shell=dash

# check the --version
if ! go version >&2 ;then
    pkg:error "fail to get version"
    return 1
fi

# test_gopath_boot(){
#     local version="${GOPATH##*/}"
#     local candidate="${GOPATH%*/"$version"}"
#     candidate="${candidate##*/}"

#     if [ "$candidate" = "go" ] && [ -n "$version" ];then
#         x path | grep -q "$GOPATH/Go_package/bin" || {
#             pkg:error "Test path failed"
#             return 1
#         }
#         x path | grep -q "$GOPATH/bin" || {
#             pkg:error "Test path failed"
#             return 1
#         }
#     else
#         pkg:error "Test boot failed "
#         return 1
#     fi
#     return 0
# }

# test_gopath_boot
