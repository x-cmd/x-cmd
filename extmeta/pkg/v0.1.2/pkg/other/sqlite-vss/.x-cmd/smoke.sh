# shellcheck shell=dash

# check the --version

xbin_path="$(___x_cmd_pkg_xbin_path sqlite-vss)"
archive_path="${xbin_path%/sqlite-vss.sh}"
vss_version="$(printf "%s\n%s\n%s" ".load $archive_path/vector0" ".load $archive_path/vss0" "select vss_version();" | x sqlite3)"
if [ "$vss_version" != "$(___x_cmd_pkg_default_version sqlite-vss)" ] ;then
    pkg:error "fail to get version"
    return 1
fi
