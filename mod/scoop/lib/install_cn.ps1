# install
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# irm -useb get.scoop.sh | iex
irm https://ghp.ci/https://raw.githubusercontent.com/duzyn/scoop-cn/master/install.ps1 | iex
scoop bucket add main

# config
# scoop config SCOOP_REPO https://ghproxy.com/github.com/ScoopInstaller/Scoop
# scoop bucket rm main
# scoop bucket add main https://ghproxy.com/github.com/ScoopInstaller/Main
