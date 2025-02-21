# shellcheck shell=dash
x touch test.txt
if ! horcrux -n 2 -t 2 split test.txt 2>&1;then
    pkg:error "fail to split file"
    return 1
fi
