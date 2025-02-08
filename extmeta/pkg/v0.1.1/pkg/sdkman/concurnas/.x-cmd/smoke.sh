# shellcheck shell=dash

# check the --version

___x_cmd env use java=v15.0.2-open
conc << EOF
/exit
EOF
if ! [ $? -eq 0 ] ;then
    pkg:error "fail to get version"
    return 1
fi
