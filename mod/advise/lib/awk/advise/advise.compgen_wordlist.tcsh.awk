
function comp_advise_str_style_bash(v, d, sep,      _res){
    if ((d != "") && ( ADVISE_WITHOUT_DESC != 1 )) {
        _res = sprintf("%-"MAX_W"s", v) "(" d ")"
        gsub( " ", "_", _res )
    }
    else _res = v

    return _res sep
}

( arr[ $1 ] != 1 ){
    end_sep = $1
    v = candidate_prefix $2
    d = $3
    if (( v == "" ) || ( arr[ v ] == 1 ) || ((current != "") && (v !~ "^"current))) next

    arr[ v ] = 1
    if (( d != "" ) && ( (id = arr[ d, "DESC_ID" ])  > 0 )) {
        arr[ id, "VAL", (++ arr[ id, "VALL" ]) ] = v
        w = arr[ id, "WIDTH" ] = arr[ id, "WIDTH" ] + length(v) + 4
    } else {
        NUM ++
        w = length(v)
        arr[ NUM, "VAL", (arr[ NUM, "VALL" ] = 1) ] = v
        arr[ NUM, "DESC" ] = d
        arr[ NUM, "END_SEP" ] = end_sep
        arr[ NUM, "WIDTH" ] = w
        arr[ d, "DESC_ID" ] = NUM
        if ( NUM >= maxitem ) exit(0)
    }

    if (MAX_W < w) MAX_W = w
}

END{
    if (NUM == 1) {
        l = arr[ 1, "VALL" ]
        if (l == 1) print arr[ 1, "VAL", 1 ] arr[ 1, "END_SEP" ]
        else {
            for (j=1; j<=l; ++j) {
                print comp_advise_str_style_bash( arr[ 1, "VAL", j ], arr[1, "DESC"], arr[ 1, "END_SEP" ] )
            }
        }
    }
    else {
        for (i=1; i<=NUM; ++i){
            l = arr[ i, "VALL" ]
            v = arr[ i, "VAL", 1 ]
            for (j=2; j<=l; ++j) v = v "    " arr[ i, "VAL", j ]
            print comp_advise_str_style_bash(v, arr[i, "DESC"], arr[i, "END_SEP"])
        }
    }
}
