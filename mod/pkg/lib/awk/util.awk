
# Section: init table
function pkg_init_table( jobj, table, table_kp,
    pkg_name, version, osarch,
    _os_arch, _final_version ){

    # Predefined env variables
    pkg_add_table( "sb_branch", "main", table, table_kp )

    pkg_add_table( "osarch", osarch, table, table_kp )
    pkg_add_table( "version", version, table, table_kp )

    pkg_add_table( "sb_repo", pkg_name, table, table_kp )
    pkg_add_table( "sb_gh", "https://raw.githubusercontent.com/static-build/%{sb_repo}/%{sb_branch}/bin", table, table_kp )
    pkg_add_table( "sb_gt", "https://gitcode.net/x-bash/%{sb_repo}/-/raw/%{sb_branch}/bin", table, table_kp )
    pkg_add_table( "sb_gc", "https://gitcode.net/x-bash/%{sb_repo}/-/raw/%{sb_branch}/bin", table, table_kp )

    pkg_copy_table( jobj, jqu(pkg_name) SUBSEP jqu("meta"), table, table_kp )

    pkg_modify_table_by_meta_rule( table, table_kp, jobj, pkg_name)

    _final_version = table_version( table, pkg_name)
    if ( _final_version != "" ) {
        pkg_copy_table( jobj, pkg_kp( pkg_name, "version", juq(_final_version), osarch), table, table_kp )
    }

    split( juq( table_osarch( table, pkg_name ) ), _os_arch, "/" )
    pkg_add_table( "os", _os_arch[1], table, table_kp )
    pkg_add_table( "arch", _os_arch[2], table, table_kp )
}

function pkg_modify_table_by_meta_rule( table, table_kp, jobj, pkg_name,         _version_osarch, _rule_kp, _rule_l, i ,k, _kpat){
    _version_osarch = table_version_osarch( table, pkg_name ) # May define version or osarch (as default) in the meta file
    _rule_kp = pkg_kp( pkg_name, "meta", "rule" )
    _rule_l = jobj[ _rule_kp L ]
    for (i=1; i<=_rule_l; ++i) {
        k = jobj[ _rule_kp, i ]
        _kpat = juq( k )
        gsub("\\*", "[^/]+", _kpat)
        if ( match( _version_osarch, "^" _kpat ) ) {
            pkg_copy_table( jobj, _rule_kp SUBSEP k, table, table_kp )
            _version_osarch = table_version_osarch( table, pkg_name )
        }
    }
}

function pkg_get_version_or_head_version( jobj, table, pkg_name,            _final_version ){
    _final_version = table_version( table, pkg_name )
    if (_final_version ~ /^".*"$/) _final_version = juq(_final_version)
    if ( _final_version != "" ) return _final_version
    else if ( jobj[ jqu(pkg_name), jqu("version") L ] <= 0 ) return
    else return juq(jobj[ jqu( pkg_name ), jqu("version"), 1 ])
}

function pkg_add_table( k, v, table, table_kp,  l ){
    k = jqu(k)
    table[ table_kp ] = "{"
    if ( table[ table_kp, k ] == "" ) {
        table[ table_kp L ] = ( l = table[ table_kp L ] + 1 )
        table[ table_kp, l ] = k
    }
    table[ table_kp, k ] = jqu(v)
}
# EndSection

# Section: copy
function pkg_copy_table(src_obj, src_kp, table, table_kp,       k){
    if ((k = src_obj[ src_kp ]) == "") return
    table[ table_kp ] = k
    if (src_obj[ src_kp ] == "{") return pkg_copy_table___dict(src_obj, src_kp, table, table_kp)
    if (src_obj[ src_kp ] == "[") return pkg_copy_table___list(src_obj, src_kp, table, table_kp)
}

function pkg_copy_table___dict( src_obj, src_kp, table, table_kp,       l, i, k, _l ){
    l = src_obj[ src_kp L ]

    for (i=1; i<=l; ++i) {
        k = src_obj[ src_kp, i ]
        if (k == "\"rule\"") continue       # skip the rule
        if ( table[ table_kp, k ] == "" ) {
            table[ table_kp L ] = ( _l = table[ table_kp L ] + 1 )
            table[ table_kp, _l ] = k
        }
        pkg_copy_table( src_obj, src_kp SUBSEP k, table, table_kp SUBSEP k )
    }
}

function pkg_copy_table___list( src_obj, src_kp, table, table_kp,       l, i, _l ){
    l = src_obj[ src_kp L ]
    table[ table_kp L ] = l

    for (i=1; i<=l; ++i) {
        pkg_copy_table( src_obj, src_kp SUBSEP i, table, table_kp SUBSEP i )
    }
}
# EndSection

# Section: table
function table_version_osarch( table, pkg_name ){
    return juq( table_version( table, pkg_name ) ) "/" juq( table_osarch( table, pkg_name ) )
}

function table_attr( table, pkg_name, attr_name ){
    return table[ jqu( pkg_name ), attr_name ]
}

function table_version( table, pkg_name ){
    return table_attr( table, pkg_name, jqu("version") )
}

function table_osarch( table, pkg_name ){
    return table_attr( table, pkg_name, jqu("osarch") )
}

function table_eval( table, pkg_name, str ){
    return pkg_eval_str( str, table, pkg_name )
}

function pkg_eval_str( str, table, pkg_name,            _attempt, t, p, _newstr ){
    pkg_name = jqu( pkg_name )

    str = juq(str)
    while ( match( str, "%\\{[^}]+\\}" ) ) {
        if ( ++_attempt > 100 ) exit_msg( sprintf( "Exit because replacement attempts more than 100[%s]: %s", _attempt, str ) )
        p = substr( str, RSTART+2, RLENGTH-3 )
        t = table[ pkg_name SUBSEP jqu(p) ]
        if (t ~ /^".*"$/) t = juq(t)
        # if ( t == "" ) exit_msg( sprintf("Unknown pattern[%s] from str: %s", (pkg_name SUBSEP jqu(p)), str) )
        _newstr = substr( str, 1, RSTART-1 ) t substr( str, RSTART + RLENGTH )
        if (_newstr == str)  exit_msg( sprintf("Logic error. Target not changed: %s", str) )
        str = _newstr
    }

    return str
}


# EndSection

# Section: parsing

function parse_pkg_meta_json(o, pkg_name, text) {
    return jqparse_dict0( text, o, jqu(pkg_name) SUBSEP jqu("meta") )
}

function parse_pkg_version_json(o, pkg_name, text) {
    return jqparse_dict0( text, o, jqu(pkg_name) SUBSEP jqu("version") )
}

function pkg_kp(a1, a2, a3, a4, a5, a6, a7, a8, a9,
    a10, a11, a12, a13, a14, a15, a16, a17, a18, a19,
    _ret){
    _ret = ""
    if (a1 == "")   return _ret;  _ret = jqu(a1)
    if (a2 == "")   return _ret;  _ret = _ret SUBSEP jqu(a2)
    if (a3 == "")   return _ret;  _ret = _ret SUBSEP jqu(a3)
    if (a4 == "")   return _ret;  _ret = _ret SUBSEP jqu(a4)
    if (a5 == "")   return _ret;  _ret = _ret SUBSEP jqu(a5)
    if (a6 == "")   return _ret;  _ret = _ret SUBSEP jqu(a6)
    if (a7 == "")   return _ret;  _ret = _ret SUBSEP jqu(a7)
    if (a8 == "")   return _ret;  _ret = _ret SUBSEP jqu(a8)


    if (a9 == "")   return _ret;  _ret = _ret SUBSEP jqu(a9)
    if (a10 == "")  return _ret;  _ret = _ret SUBSEP jqu(a10)
    if (a11 == "")  return _ret;  _ret = _ret SUBSEP jqu(a11)
    if (a12 == "")  return _ret;  _ret = _ret SUBSEP jqu(a12)
    if (a13 == "")  return _ret;  _ret = _ret SUBSEP jqu(a13)
    if (a14 == "")  return _ret;  _ret = _ret SUBSEP jqu(a14)
    if (a15 == "")  return _ret;  _ret = _ret SUBSEP jqu(a15)
    if (a16 == "")  return _ret;  _ret = _ret SUBSEP jqu(a16)
    if (a17 == "")  return _ret;  _ret = _ret SUBSEP jqu(a17)
    if (a18 == "")  return _ret;  _ret = _ret SUBSEP jqu(a18)
    if (a19 == "")  return _ret;  _ret = _ret SUBSEP jqu(a19)

    return ret
}

# EndSection
