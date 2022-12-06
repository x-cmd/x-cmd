{
    if ($0 == "") next
    installed_pkg_name[ ++ installed_pkg_arrl ] = $1
    installed_pkg_version[ installed_pkg_arrl ] = $2
    _pkg_name_len = length($1)
    _pkg_version_len = length($2)
    if( installed_pak_name_max_len < _pkg_name_len ) installed_pak_name_max_len = _pkg_name_len
    if( installed_pkg_version_max_len < _pkg_version_len ) installed_pkg_version_max_len = _pkg_version_len
}

function pkg_print_installed_list( _pkg_name, _version,       _cat_meta_json, _cat_version_json, _final_version ){
    PKG_NAME = pkg_local[ _pkg_name ]
    _cat_meta_json = "cat " PKG_RAWPATH "/" PKG_NAME "/meta.tt.json 2>/dev/null"
    _cat_version_json = "cat " PKG_RAWPATH "/" PKG_NAME "/version.tt.json 2>/dev/null"
    _cat_meta_json | getline meta_json
    _cat_version_json | getline version_json

    parse_pkg_meta_json( jobj, PKG_NAME, meta_json )
    parse_pkg_version_json( jobj, PKG_NAME, version_json )

    pkg_init_table( jobj, table, jqu(PKG_NAME), PKG_NAME, "", OSARCH )

    _final_version = pkg_get_version_or_head_version( jobj, table, PKG_NAME)

    if ( _version == _final_version ) print str_pad_right(_pkg_name, installed_pak_name_max_len) " " str_pad_right(_version,installed_pkg_version_max_len) TH_THEME_COLOR " (default)\033[0m"
    else print str_pad_right(_pkg_name, installed_pak_name_max_len) " " str_pad_right(_version,installed_pkg_version_max_len)

    delete jobj
    delete table
}

END {
    local_listl = split(LOCAL_LIST, local_list, "\t")
    for (i=1; i<=local_listl; ++i) {
        _pkg_str = local_list[i]
        _idx = index( _pkg_str, "/" )
        pkg_local[ substr(_pkg_str, _idx+1) ] = _pkg_str
    }
    for (j=1; j<=installed_pkg_arrl; ++j) {
        pkg_print_installed_list( installed_pkg_name[j], installed_pkg_version[j] )
    }
}
