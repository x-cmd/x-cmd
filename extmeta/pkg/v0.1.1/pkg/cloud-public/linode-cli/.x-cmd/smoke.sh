# shellcheck shell=dash

# csvkite: csvclean,csvcut,csvformat,csvgrep,csvjoin,csvjson,csvlook,csvpy,csvsort,csvsql,csvstack,csvstat,in2csv,sql2csv
if ! linode-cli --version 2>&1;then
    pkg:error "linode-cli  fail to get version"
    return 1
fi
