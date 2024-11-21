BEGIN{
    tsv_init()
}

function tsva_handle_header(){
    HEADER_LENGTH = NF
    for (i=1; i<=NF; ++i) {
        H2I[ H[ i ]     = $i ]             = i
        H2I[ HL[ i ]    = tolower($i) ]    = i
    }
}

function h2i( e,        _res, i ){
    if ( (_res = H2I[ e ]) != "" ) return _res
    for (i=1; i<=HEADER_LENGTH; ++i) {
        if (HL[i] ~ e)    return i
    }
}

function v( str,    i ){
    if ( (i=H2I[ str ]) != "")      return $i
    if ( (i=int(str))   == str )    return $i
    return ""
}

function s( str,    i ){
    if ( (i=H2I[ str ]) != "")      return $i
    if ( (i=int(str))   == str )    return $i

    # select all of the values that match the regex

    for (i=1; i<=headerl; ++i) {
        if (HL[i] ~ str)    return $i
    }
}

BEGIN{
    if (TSVA_HAS_HEADER) {
        readline()
        tsva_handle_header()
    }
}
