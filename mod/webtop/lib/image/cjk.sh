
# first install x-cmd
eval "$(curl https://get.x-cmd.com)"

if ___x_cmd_hascmd apk; then
    ! ___x_cmd websrc is cn || ___x_cmd apk mirror set
    ___x_cmd apk add font-noto-cjk
elif ___x_cmd hascmd apt; then
    ! ___x_cmd websrc is cn || ___x_cmd apt mirror set
    ___x_cmd apt install --yes fonts-noto-cjk
elif ___x_cmd hascmd dnf; then
    ! ___x_cmd websrc is cn || ___x_cmd dnf mirror set
    ___x_cmd dnf install -y google-noto-cjk-fonts # fonts-noto-cjk
elif ___x_cmd hascmd pacman; then
    ! ___x_cmd websrc is cn || ___x_cmd pacman mirror set
    yes Y | pacman -Sy --disable-download-timeout noto-fonts-cjk
fi
