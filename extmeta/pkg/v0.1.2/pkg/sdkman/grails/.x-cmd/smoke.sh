# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open

# check the --version

if ! grails --version 2>&1;then
    pkg:error "fail to get version"
    return 1
fi
