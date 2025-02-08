# shellcheck shell=dash

if ! minikube version ;then
    pkg:error "fail to get version"
    return 1
fi
