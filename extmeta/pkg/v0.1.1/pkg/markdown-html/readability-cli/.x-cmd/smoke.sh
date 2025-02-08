# shellcheck    shell=dash
x os name_
[ "$___X_CMD_OS_NAME_" != "win" ] || return 1
if ! readable --version 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
