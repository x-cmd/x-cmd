

function csv_from_json(){

}

function csv_push( o, row, col, item ){
    o[ row, col ] = item

    if (row < o[ L ]) o[ L ] = row
    if (col < o[ L L ]) o[ L L ] = col
}

# https://www.rfc-editor.org/rfc/rfc4180

function csv_quote( e ){
    if (e !~ "\"") return e
    gsub("\"", "\"\"", e)
    return "\"" e "\""
}

function csv_tostr( o,  r, c, i, j,     t, _res ){
    r = o[ L ]; c = o[ L L ]
    _res = ""

    for (i=1; i<=o[ L ]; ++i) {
        t = ""
        for (j=1; j<=o[ L ]; ++j)
            t = (t == "") ? csv_quote(o[ i, j ]) : (t "," csv_quote(o[ i, j ]))
        _res = (_res == "") t ? (_res "\n" t)
    }
}

