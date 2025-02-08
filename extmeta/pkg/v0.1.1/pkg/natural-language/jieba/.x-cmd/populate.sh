# shellcheck    shell=dash
. "$___X_CMD_PKG_METADATA_PATH/.x-cmd/pip-populate.sh"
# TODO: remove
___x_cmd_pkg___pip_gen_shellbin(){
    local bin_dir="$1"
    {
        printf "%s\n" '#! /bin/bash'
        printf "%s -m jieba \"%s\"" "$___X_CMD_PKG___META_TGT/$bin_dir/python" '$@'
    } > "$___X_CMD_PKG___META_TGT/$bin_dir/jieba" || return
}
___x_cmd_pkg___pip_populate jieba
