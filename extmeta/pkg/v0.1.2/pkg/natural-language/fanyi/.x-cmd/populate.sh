# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/npm-populate.sh"
___x_cmd_pkg___npm_populate fanyi fy

case "$___X_CMD_PKG___META_OS" in
    linux)  pkg:warn "Try this fanyi in Linux: \`sudo apt-get install festival festvox-kallpc16k\`"
esac
