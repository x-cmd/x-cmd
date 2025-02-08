# shellcheck    shell=dash 
if ! browser-run --version 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
