# shellcheck    shell=dash
# Error: spawn festival ENOENT
# https://github.com/afc163/fanyi#error-spawn-festival-enoent

if ! fanyi --version 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
