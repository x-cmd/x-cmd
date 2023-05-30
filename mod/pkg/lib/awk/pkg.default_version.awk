
END {
    if (PANIC_EXIT != 0) exit( PANIC_EXIT )
    _final_version = pkg_get_version_or_head_version( jobj, table, PKG_NAME)
    if ( _final_version != "" ) print _final_version
    # else print "pkg: Not found version." >"/dev/stderr"
}
