# shellcheck shell=dash

# check the --version
# x os name_
# xbin_path="$(___x_cmd_pkg_xbin_path sqlite-xsv)"
# archive_path="${xbin_path%/sqlite-xsv.sh}"
# if [ "$___X_CMD_OS_NAME_" = "win" ];then
#     archive_path="$(printf "%s" "$archive_path" | sed 's/^\/c/c:/g')"
# fi
# xsv_version="$(printf "%s\n%s" ".load $archive_path/xsv0" "select xsv_version();" | x sqlite3)"
# if [ "$xsv_version" != "$(___x_cmd_pkg_default_version sqlite-xsv)" ] ;then
#     pkg:error "fail to get version"
#     return 1
# fi
return 1
