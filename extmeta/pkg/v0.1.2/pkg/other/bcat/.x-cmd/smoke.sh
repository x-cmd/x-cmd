# shellcheck    shell=dash
x os name_
if [ "$___X_CMD_OS_NAME_" = "win" ];then
  return 1
else
  if ! bcat --help 2>&1;then
    pkg:error "fail to get version"
    return 1
  fi
fi
