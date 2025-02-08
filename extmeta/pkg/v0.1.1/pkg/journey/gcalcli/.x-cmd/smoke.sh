# shellcheck    shell=dash 
if ! gcalcli --version 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
