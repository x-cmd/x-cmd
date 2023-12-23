# install
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# irm -useb get.scoop.sh | iex
irm https://cdn.jsdelivr.net/gh/duzyn/scoop-cn/install.ps1 | iex
scoop bucket add main

# config
# scoop config SCOOP_REPO https://ghproxy.com/github.com/ScoopInstaller/Scoop
# scoop bucket rm main
# scoop bucket add main https://ghproxy.com/github.com/ScoopInstaller/Main
