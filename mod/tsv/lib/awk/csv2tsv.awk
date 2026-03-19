BEGIN{
    csv_irecord_init()
    while ( (c = csv_irecord( data )) > 0 ) {
        row = CSV_IRECORD_CURSOR
        _res = csv_totcsv_item( data[ S row, 1 ] )
        for (i=2; i<=c; ++i){
            _res = _res "\t" csv_totcsv_item( data[ S row, i ] )
        }
        print _res
        fflush()
    }
    csv_irecord_fini()
}

function csv_totcsv_item(s){
    s = csv_unquote_ifmust(s)
    gsub(/\t/, "\\t", s)
    gsub(/\r/, "\\r", s)
    gsub(/\n/, "\\n", s)
    return s
}
