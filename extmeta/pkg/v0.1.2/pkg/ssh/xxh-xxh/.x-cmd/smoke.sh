# shellcheck    shell=dash
# xxh-xxh need the openssh-client
x os name_
if [ "$___X_CMD_OS_NAME_" = "win" ];then
    return 1
else
    if ! xxh --version 2>&1;then
        pkg:error "fail to get version"
        return 1
    fi
fi
