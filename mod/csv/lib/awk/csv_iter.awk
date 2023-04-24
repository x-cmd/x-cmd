{
    if ( citer() ) next
    if ( ceof() ) exit(0)
}

function ___cgetline( fp ){
    if ( fp == "" ) getline
    else            getline <fp
}

function ___cgetrec( fp,       r, b, c, i, _lastcell, line, _tmp, _tmpl,d, _data ){
    CNF = 0
    if (! ___cgetline( fp )) return 0  # false

    _data = $0
    while (_data != ""){
        line = csv_trim(_data)
        gsub( CSV_CELL_PAT, "&\n", line )

        _tmpl = split(line, _tmp, ",\n")
        for (i=1; i<_tmpl; ++i) CROW[ ++ CNF ] = _tmp[ i ]

        # Tip: 若最后一个元素是个空值，切分出来只是个空值，不会有\n
        # Tip: 若最后一个元素是完整的（非空值），那必然是加了\n
        # Tip: 若最后一个元素是不完整的，有\n
        # Tip: 所以，需要判断最后一个元素是否是半个quote-string
        _lastcell = _tmp[_tmpl]
        if ( _lastcell !~ "^\"" ___CSV_CELL_PAT_STR_CONTENT "$" ) {
            CROW[ ++ CNF ] = csv_trim(_lastcell)
            break
        }

        b = _lastcell
        gsub("\n$", "", b)
        while (1){
            if (! ___cgetline( fp )) return -1
            _data = $0

            if (! match( _data, CSV_CELL_NEXT_PAT )) {
                b = b "\n" CSV_ITER_DATA
            } else {
                c = substr( _data, RSTART, RLENGTH )
                _data = substr( _data, RLENGTH+1 )

                gsub(",$", "", c)
                CROW[ ++ CNF ] = csv_trim(b "\n" c)
                break
            }
        }
    }
}

function creset( ){
    CNR = 0
    CNF = 0
}

function citer( fp,         r ){
    r = ___cgetrec( fp )
    if (r)  CNR ++
    else if (fp != "")) close(fp)
    return r
}

function cparse( fp, obj, kp,       _kp, i ){
    while (citer( fp )){
        _kp = kp SUBSEP CNR
        for (i=1; i<=CNF; ++i) obj[ _kp ] = cget( i )
        obj[ _kp ] = CNF
    }
}

function cget( i ){
    return CROW[ i ]
}

function cval( i,   v ){
    v = cget( i )
    if (v ~ "^\"")  return csv_uq( v )
    else            return v
}

# x csva 1:3 3:2 |

BEGIN{
    while(jiter()){
        # k, v
    }
}
x csv awk '
BEGIN{

}
'


x csv awk '
function work{

}

BEGIN{

}

'


function jitera(){
    while (!jiter()){
        if (jiter_eof()) return 0
    }
}

{

}

{

}
