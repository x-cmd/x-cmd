# shellcheck shell=dash

___x_cmd___hook_sqlite_simple_populate(){
    local bin_name="libsimple"
    local archive_path="$___X_CMD_PKG___META_TGT"
    if ! command -v sqlite3 >/dev/null 2>&1; then
        x env use sqlite3
    fi
    if [ "$___X_CMD_PKG___META_OS" = "win" ];then
        bin_name="simple"
        archive_path="$(printf "%s" "$archive_path" | sed 's/^\/c/c:/g')"
    fi
    printf "%s\n" "sqlite3 -cmd '.load $archive_path/$bin_name'" > "$archive_path/sqlite-simple.sh"
}

___x_cmd___hook_sqlite_simple_populate
