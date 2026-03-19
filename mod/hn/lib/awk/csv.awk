{
    _arrl = json_split2tokenarr( _arr, $0 )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if (JITER_LEVEL == 0) {
            if (JITER_CURLEN == 1) print hn_json_to_csv_title()
            print hn_json_to_csv_line(o, SUBSEP "\"" JITER_CURLEN "\"")
            fflush()
        }
    }
}
