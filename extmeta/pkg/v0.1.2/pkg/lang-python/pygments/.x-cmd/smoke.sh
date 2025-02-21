# shellcheck    shell=dash
if ! pygmentize -V 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
