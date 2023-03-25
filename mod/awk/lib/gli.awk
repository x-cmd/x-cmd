

BEGIN{
    LINEITER_BUFFER_CURRENT = 0
    LINEITER_BUFFER_LEN = 0
}

function gli_init(){
    LINEITER_BUFFER_CURRENT = 0
    LINEITER_BUFFER_LEN = 0
    RS = "\n"
}

# BEGIN{
#     RS = "\r?\n"
# }

function gli_buffer_put( line ){
    LINEITER_BUFFER[ ++ LINEITER_BUFFER_LEN ] = line
}

function gli_fetch( linenum, i,     line ){
    for (i=1; i<=linenum; ++i) {
        if (! getline line) return 0
        gli_buffer_put( line )
    }
    return 1
}

function gli_buffer_len( ){
    return LINEITER_BUFFER_LEN
}

function gli_buffer_get( i ){
    return LINEITER_BUFFER[ i ]
}

function gli_next(){
    if (LINEITER_BUFFER_CURRENT >= LINEITER_BUFFER_LEN) {
        return getline
    } else {
        $0 = LINEITER_BUFFER[ ++LINEITER_BUFFER_CURRENT ]
        return 1
    }
}

