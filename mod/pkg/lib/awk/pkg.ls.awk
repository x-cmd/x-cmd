{
    if ($0 == "") next
    arr_push( installed_pkg_name, $1 )
    arr_push( installed_pkg_version, $2 )
    arr_push( installed_pkg_osarch, $3 )

    if( installed_pak_name_max_len < (_pkg_name_len = length($1)) )         installed_pak_name_max_len = _pkg_name_len
    if( installed_pkg_version_max_len < (_pkg_version_len = length($2)) )   installed_pkg_version_max_len = _pkg_version_len
    if( installed_pkg_osarch_max_len < (_pkg_osarch_len = length($2)) )     installed_pkg_osarch_max_len = _pkg_osarch_len
}

function pkg_print_installed_list( name, version, osarch,       _final_version, jobj, table, s ){
    _pkg_name = pkg_local[ name ]

    parse_pkg_meta_json( jobj, _pkg_name, cat( PKG_RAWPATH "/" _pkg_name "/meta.tt.json" ) )
    parse_pkg_version_json( jobj, _pkg_name, cat( PKG_RAWPATH "/" _pkg_name "/version.tt.json" ) )

    pkg_init_table( jobj, table, jqu(_pkg_name), _pkg_name, "", ((osarch != "") ? osarch : OSARCH) )

    _final_version = pkg_get_version_or_head_version( jobj, table, _pkg_name)

    if (osarch == "") s = ""
    else s = str_pad_right(osarch, installed_pkg_osarch_max_len) " "

    s = s str_pad_right(name, installed_pak_name_max_len) " " str_pad_right(version, installed_pkg_version_max_len)
    if ( version == _final_version ) s = s TH_THEME_COLOR " (default)\033[0m"
    print s
}

END {
    local_listl = split(LOCAL_LIST, local_list, "\t")
    for (i=1; i<=local_listl; ++i) {
        _pkg_str = local_list[i]
        _idx = index( _pkg_str, "/" )
        pkg_local[ substr(_pkg_str, _idx+1) ] = _pkg_str
    }

    l = arr_len( installed_pkg_name )
    for (j=1; j<=l; ++j) pkg_print_installed_list( installed_pkg_name[j], installed_pkg_version[j], installed_pkg_osarch[j] )
}
