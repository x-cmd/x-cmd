# shellcheck shell=dash

if ! mosquitto -h | grep "mosquitto version" ;then
    pkg:error "fail to get version"
    return 1
fi
