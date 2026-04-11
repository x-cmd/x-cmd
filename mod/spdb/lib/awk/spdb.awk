
function spdb_getdate( _current_date ) {
    "date +%Y%m%d-%H%M%S-%Z" | getline _current_date
    return _current_date
}

function spdb_getnextfp( prefixfp ){
    return prefixfp "/" spdb_getdate( )
}
