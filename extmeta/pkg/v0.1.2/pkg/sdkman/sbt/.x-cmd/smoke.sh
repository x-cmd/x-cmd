# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open
x os name_
if [ "$___X_CMD_OS_NAME_" = "win" ];then
    return 1
else
    if ! sbt --version 2>&1;then
        pkg:error "fail to get version"
        return 1
    fi
fi
