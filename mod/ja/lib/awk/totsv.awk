# Copy the code from tocsv.awk and change the LINE 23 only

BEGIN{
    args = ENVIRON[ "args" ]
    ARG_ARR_L = split( args, ARG_ARR, "\001" )
    PATARR[1] = "^\"[0-9]+\"$"
    # PATARR[2] = "^\"[0-9]+\"$"
    PATARRL   = 1
    EXIT_ERROR = true
}

# TODO: Performance issue. There is a better design. Serialized object by object, using hash access instead of regex match.
{
    if ($0 == "") next
    _item_arrl = json_split2tokenarr( _item_arr, $0 )
    for (_i=1; _i<=_item_arrl; ++_i) {
        if ( jiter_regexarr_parse( o, _item_arr[_i], PATARRL, PATARR ) == false )    continue
        _res = ""
        EXIT_ERROR = false
        for (i=1; i<=ARG_ARR_L; ++i){
            cell = jstr1(o, ARG_ARR[i])
            if (cell ~ "^\"") cell = juq(cell)
            _res = (( i == 1 ) ? "" : _res "\t" ) tsv_esacpe(cell)
        }
        print _res
        fflush()
        delete o
    }
}
END{    exit( EXIT_ERROR );    }

