# shellcheck    shell=dash
if ! pnpm --version 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
# if ! pnpx --version 2>&1;then
#   pkg:error "fail to get version"
#   return 1
# fi
