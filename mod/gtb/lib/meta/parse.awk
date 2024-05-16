BEGIN{
    grep_kw = ENVIRON[ "grep_kw" ]
    EXITCODE = 1
    ISLOWERCASE = 1
    print "Text#,Type,Issued,Title,Language,Authors,Subjects,LoCC,Bookshelves"
}

NR>1{
    l = split( grep_kw, arr, "")
    for (i=1; i<=l; ++i) {
        _item = arr[i]
        _ord_item = ord(_item)
        if ( ! ord_is_lowercase(_ord_item) ) {
            ISLOWERCASE = 0
            break
        }
    }

    for (i=1; i<=CNF; ++i){
        data = ( ISLOWERCASE == 1 ) ? tolower( cval(i) ) : cval(i)
        if ( match(data, grep_kw) ){
            EXITCODE=0
            print cget_row()
            break
        }
    }
}

END{
    if (EXITCODE != 0) log_error("gtb", "Not found " grep_kw)
    exit(EXITCODE)
}

# function parse(data, grep_kw,  data_1, l, _lastcell, _tmp  ){
#     arr[ NR ] = $0
#     if ( CSVA_COMPLETE == false ) {
#         print $0
#         CSVA_COMPLETE = true
#         next
#     }

#     if ( match($0, grep_kw) ) {
#         if ( $1 !~ /^[0-9]/ ) print arr[ NR-1 ]

#         gsub( CSV_CELL_PAT, "&\n", data )
#         l = split(data, _tmp, ",\n")
#         _lastcell = _tmp[l]
#         if ( _lastcell ~ "^\"" ___CSV_CELL_PAT_STR_CONTENT "$" ) {
#             print $0
#             return CSVA_COMPLETE = false
#         }
#         print $0
#     }
# }


