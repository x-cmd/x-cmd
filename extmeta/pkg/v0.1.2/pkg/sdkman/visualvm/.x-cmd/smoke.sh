# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open

output=$(visualvm --help)

if [ -n "$output" ];then
    return 0
else
    return 1
fi
