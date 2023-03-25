
# https://www.rfc-editor.org/rfc/rfc4180

# Section: Iterator Mode
BEGIN{
    CSV_ITER_MODE_GETLINE = 1
    CSV_ITER_MODE_BUFFER = 2

    # CSV_ITER_BUFFER[ L ] =
    CSV_ITER_BUFFER_EMPTY[ L ] = 0
    CSV_ITER_BUFFER_L = CSV_ITER_BUFFER_C = 0

    CSV_ITER_DATA = ""

    CSV_ITER_MODE = CSV_ITER_MODE_BUFFER
}

# return: boolean
function csv_iter_next( o ){
    if (CSV_ITER_MODE == CSV_ITER_MODE_BUFFER) {
        if (CSV_ITER_BUFFER_C >= CSV_ITER_BUFFER_L) return 0
        CSV_ITER_DATA = o[ ++ CSV_ITER_BUFFER_C]
        return 1
    }
    CSV_ITER_DATA = ""
    return getline CSV_ITER_DATA
}

# EndSection

# Section: irecord
function csv_irecord_init(){
    CSV_IRECORD_ORS = RS
    # Tip: Each record is located on a separate line, delimited by a line break (CRLF).
    RS = "\n"     # 如果设置了 \r?\n 以后是个大问题
    CSV_ITER_MODE = CSV_ITER_MODE_GETLINE
    CSV_IRECORD_CURSOR = 0
}

# 若c为零，输入流已结束
function csv_irecord( arr, kp,      c ){
    if (! csv_iter_next( CSV_ITER_BUFFER_EMPTY )) return -1
    c = csv_parse_iter_all___record( CSV_ITER_BUFFER_EMPTY, arr, kp SUBSEP (++CSV_IRECORD_CURSOR) )
    if (c < 0) exit_now(1)
    return c
}

function csv_irecord_fini(){
    RS = CSV_IRECORD_ORS
}

### 主函数
function csv_irecord__all( arr, kp ){
    csv_irecord_init()
    while (csv_irecord( arr, kp )) {}
    csv_irecord_fini()
}
# EndSection

### 主函数
# return: length of the arr, the total record number
function csv_parse( buffer, arr, kp ){
    CSV_ITER_BUFFER_C = 0
    CSV_ITER_BUFFER_L = buffer[ L ]
    CSV_ITER_MODE = CSV_ITER_MODE_BUFFER
    return csv_parse_iter_all( buffer, arr, kp )
}

function csv_parse_iter_all( buffer, arr, kp,       l, c ){
    l = 0
    while (csv_iter_next( buffer )) {
        c = csv_parse_iter_all___record( buffer, arr, kp SUBSEP (++l) )
        if (c < 0){
            # TODO: log error
            exit_now(1)
        }
    }
    arr[ kp L L ] = c
    return arr[ kp L ] = l
}

function csv_parse_iter_all___put( arr, key, value ){
    arr[ key ] = (value ~ "^\"") ? csv_unquote( value ) : value
}

BEGIN{
    ___CSV_CELL_PAT_STR_CONTENT = "((\"\")|[^\"])*"
    ___CSV_CELL_PAT_STR_QUOTE = "\"" ___CSV_CELL_PAT_STR_CONTENT "\""
    ___CSV_CELL_PAT_ATOM = "[^\",]+"

    ___CSV_CELL_PAT_STR_LEFT_HALF = "\"" ___CSV_CELL_PAT_STR_CONTENT "$"

    ___CSV_CELL_PAT_WHOLE = sprintf( "((%s)|(%s))*($|,)", ___CSV_CELL_PAT_STR_QUOTE, ___CSV_CELL_PAT_ATOM )
    CSV_CELL_PAT = sprintf("(%s)|(%s)", ___CSV_CELL_PAT_STR_LEFT_HALF, ___CSV_CELL_PAT_WHOLE)

    ___CSV_CELL_PAT_STR_RIGHT = ___CSV_CELL_PAT_STR_CONTENT "\""
    CSV_CELL_NEXT_PAT = "^" ___CSV_CELL_PAT_STR_RIGHT "(,|$)"
}

function csv_parse_iter_all___record( buffer, arr, kp,    l, b, c, i, _lastcell, line, _tmp, _tmpl,d ){
    l = 0
    while (CSV_ITER_DATA != "") {
        line = csv_trim(CSV_ITER_DATA)
        gsub( CSV_CELL_PAT, "&\n", line )

        _tmpl = split(line, _tmp, ",\n")
        for (i=1; i<_tmpl; ++i) {
            csv_parse_iter_all___put( arr, kp SUBSEP (++l), _tmp[i] )
        }

        # Tip: 若最后一个元素是个空值，切分出来只是个空值，不会有\n
        # Tip: 若最后一个元素是完整的（非空值），那必然是加了\n
        # Tip: 若最后一个元素是不完整的，有\n
        # Tip: 所以，需要判断最后一个元素是否是半个quote-string
        _lastcell = _tmp[_tmpl]
        if ( _lastcell !~ "^\"" ___CSV_CELL_PAT_STR_CONTENT "$" ) {
            csv_parse_iter_all___put( arr, kp SUBSEP (++l), csv_trim(_lastcell) )
            break
        }

        b = _lastcell
        gsub("\n$", "", b)
        while (1){
            if (! csv_iter_next( buffer )) return -1
            if (! match( CSV_ITER_DATA, CSV_CELL_NEXT_PAT )) {
                b = b "\n" CSV_ITER_DATA
            } else {
                c = substr(CSV_ITER_DATA, RSTART, RLENGTH)
                CSV_ITER_DATA = substr(CSV_ITER_DATA, RLENGTH+1)

                gsub(",$", "", c)
                csv_parse_iter_all___put( arr, kp SUBSEP (++l), csv_trim(b "\n" c) )
                break
            }
        }
    }
    return l
}

# Section: tostring
function csv_quote( e ){
    # if (e !~ "\"") return e
    gsub("\"", "\"\"", e)
    return "\"" e "\""
}

function csv_quote_ifmust( e ){
    return (e ~ "(\")|[\r\n,]") ? csv_quote( e ) : e
}

function csv_unquote( e ){
    e = substr(e, 2, length(e)-2)
    gsub("\"\"", "\"", e)
    return e
}

function csv_dump( o, kp ){
    return csv_tostr( o, kp )
}

function csv_tostr( o, kp,         r, c, i, j, t, _res ){
    r = o[ kp L ]; c = o[ kp L L ]
    for (i=1; i<=r; ++i) {
        t = csv_dump_row( o, kp, i )
        _res = (_res == "") ? t : (_res "\n" t)
    }
    return _res
}

function csv_dump_row( o, kp, i,     c, j, _res ){
    c = o[ kp L L ]
    for (j=1; j<=c; ++j)
        _res = ((_res == "") ? "" : _res "," ) csv_quote_ifmust(o[ kp, i, j ])
    return _res
}

function csv_trim( str ){
    gsub("^[\r\n]+|[\r\n]+$", "", str)
    return str
}

# EndSection

# Section: util
function csv_from_json(){
    return 0
}

function csv_push( o, row, col, item ){
    o[ row, col ] = item

    if (row < o[ L ]) o[ L ] = row
    if (col < o[ L L ]) o[ L L ] = col
}

# EndSection

