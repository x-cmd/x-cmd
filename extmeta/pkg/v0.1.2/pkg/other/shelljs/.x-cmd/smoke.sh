# shellcheck    shell=dash
printf "var shell = require('shelljs');\nshell.echo('hello shelljs');" > ./hello.js
if ! shjs ./hello.js 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
