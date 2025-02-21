# shellcheck shell=dash

# csvkite: csvclean,csvcut,csvformat,csvgrep,csvjoin,csvjson,csvlook,csvpy,csvsort,csvsql,csvstack,csvstat,in2csv,sql2csv
if ! in2csv --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi

if ! csvcut --version 2>&1;then
    pkg:error "csvcut  fail to get version"
    return 1
fi

if ! csvjson --version 2>&1;then
    pkg:error "csvjson fail to get version"
    return 1
fi
