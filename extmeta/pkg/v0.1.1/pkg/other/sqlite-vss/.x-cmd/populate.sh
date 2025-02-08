# shellcheck shell=dash

___x_cmd___hook_sqlite_vss_populate(){
    local archive_path="$___X_CMD_PKG___META_TGT"
    if ! command -v sqlite3 >/dev/null 2>&1; then
        x env use sqlite3
    fi
    printf "%s\n" "sqlite3 -cmd '.load $archive_path/vector0' -cmd '.load $archive_path/vss0'" > "$archive_path/sqlite-vss.sh"
}

___x_cmd___hook_sqlite_vss_populate
