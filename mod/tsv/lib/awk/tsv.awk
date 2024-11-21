
function tsv_init(){
    FS = "\t"
    RS = "\n"
}

function tsv_unesacpe( v ){
    if (v ~ /\\/) {
        gsub( "\\r", "\r",  v )
        gsub( "\\n", "\n",  v )
        gsub( "\\t", "\t",  v )
        gsub( "\\", "\\\\", v )
    }
    return v
}

function tsv_esacpe( v ){
    if (v ~ /[\r\n\t\\]/) {
        gsub( "\\", "\\\\", v )
        gsub( "\r", "\\r",  v )
        gsub( "\n", "\\n",  v )
        gsub( "\t", "\\t",  v )
    }
    return v
}




