# shellcheck shell=dash
bin_name="libsimple"
xbin_path="$(___x_cmd_pkg_xbin_path sqlite-simple)"
archive_path="${xbin_path%/sqlite-simple.sh}"

x os name_
if [ "$___X_CMD_OS_NAME_" = "win" ];then
    bin_name="simple"
    archive_path="$(printf "%s" "$archive_path" | sed 's/^\/c/c:/g')"
fi

simple_string="$(printf "%s\n%s\n%s\n%s" \
".load $archive_path/$bin_name" \
"CREATE VIRTUAL TABLE t1 USING fts5(text, tokenize = 'simple');" \
"INSERT INTO t1 VALUES ('弹指一X,腾云万里');" \
"select simple_highlight(t1, 0, '[', ']') as text from t1 where text match simple_query('腾云万里');" | x sqlite3)"

if [ "$simple_string" != "弹指一X,[腾云万里]" ] ;then
    pkg:error "fail to query"
    return 1
fi
