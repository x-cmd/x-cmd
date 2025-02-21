# shellcheck shell=dash

# check the -h

x os name_
if [ "$___X_CMD_OS_NAME_" = "win" ];then
    if ! 7za -h 2>&1 ;then
        pkg:error "fail to get help"
        return 1
    fi | head -n 5
else
    if ! 7zz -h 2>&1 ;then
        pkg:error "fail to get help"
        return 1
    fi | head -n 5
fi
