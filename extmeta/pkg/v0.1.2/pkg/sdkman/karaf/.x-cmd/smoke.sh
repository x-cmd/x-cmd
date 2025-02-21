# shellcheck shell=dash
___x_cmd env use java=v21.0.2-open

# check the --version

karaf << EOF
logout
EOF
if ! [ $? -eq 0 ] ;then
    pkg:error "fail to get version"
    return 1
fi
