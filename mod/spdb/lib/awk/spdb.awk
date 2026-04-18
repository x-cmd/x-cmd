
BEGIN{
    LATEST_INDEX = ""
}

function spdb_file_exist( fp, _ret ){
    _ret = (getline a<fp)
    close(fp)
    return (_ret != -1)
}

function spdb_file_readline( fp, _ret, _line ){
    _line = ""
    _ret = (getline _line <fp)
    close( fp )

    return ( ( _ret <= -1 ) ? "" : _line )
}

function spdb_file_linecount( fp, _ret, _line ){
    _ret = (getline _line <fp)
    if (_ret != 1)  return _ret

    while (getline _line <fp) {
        _ret ++
    }

    return _ret
}

function spdb_find_latest_index( prefixfp,  _latest_fp, i ){
    # TODO: Using devide and conqure.
    for (i=0; i<=1000000; ++i) {
        if (! spdb_file_exist( prefixfp ".SPDB." i )) break
    }
    return (i-1)
}

function spdb_getdate( _current_date ) {
    "date +%Y%m%d-%H%M%S-%Z" | getline _current_date
    return _current_date
}

function spdb_getnextfp( prefixfp,  _latest_fp ){
    _latest_fp = ( prefixfp ".SPDB.LATEST" )

    if (LATEST_INDEX == "") {
        LATEST_INDEX = spdb_file_readline( latest_fp )

        if ( LATEST_INDEX == "" ) {
            LATEST_INDEX = spdb_find_latest_index( prefixfp )
            #
            LATEST_INDEX = LATEST_INDEX + 1
        }
    }

    print LATEST_INDEX >_latest_fp
    fflush( _latest_fp )
    close( _latest_fp )

    return prefixfp ".SPDB." LATEST_INDEX
}
