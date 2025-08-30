
function tsv_init(){
    FS = "\t"
    RS = "\n"
}

function tsv_unesacpe( v,   _sw ){
    if (v ~ /\\/) {
        if (gsub( /\\\\/,   "\n", v ))    _sw = 1

        gsub( /\\r/,    "\r",   v )
        if (_sw == 1)   gsub( "\n",   "\r", v )

        gsub( /\\n/,    "\n",   v )
        gsub( /\\t/,    "\t",   v )

        if (_sw == 1)   gsub( "\r",   "\\", v )
    }
    return v
}

function tsv_esacpe( v ){
    if (v ~ /[\r\n\t\\]/) {
        # gsub( "\\", "\\\\", v )
        gsub( "\\\\", "&\\", vd )
        gsub( "\r", "\\r",  v )
        gsub( "\n", "\\n",  v )
        gsub( "\t", "\\t",  v )
    }
    return v
}




