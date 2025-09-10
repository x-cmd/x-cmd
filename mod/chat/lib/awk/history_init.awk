{
    fp = $2
    jiparse2leaf_fromfile( o, fp, fp )
    if ( ! cat_is_filenotfound() ) {
        text = str_trim(juq(o[ fp, "\"question\"" ]))
        gsub( "(\\\\|[ \t\b\v\n])*$", "", text )
        if ( arr[ text ] != 1 ) {
            arr[ text ] = 1
            printf("\001\002\003 %s\n", text)
        }
    }
    delete o
}
