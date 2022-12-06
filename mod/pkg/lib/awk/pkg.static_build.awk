
function handle( varname, val ){
    print varname "=" shqu1( val )
}

END {
    prefix = jqu(PKG_NAME) SUBSEP jqu("static-build")
    _sb_attr = juq( table[ prefix ] )
    if ( "{" != _sb_attr ) {
        _idx = index( _sb_attr, "/" )
        handle("sb_repo", substr( _sb_attr, 1, _idx - 1) )
        handle("sb_app", substr( _sb_attr, _idx + 1) )
    } else {
        l = table[ prefix L ]
        for (i=1; i<=l; ++i) {
            _k = table[ prefix, i ]
            handle( "sb_" juq( _k ), juq( table[ prefix, _k] ) )
        }
    }
}
