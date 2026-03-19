{
    if ( $0 ~ "^@@[0-9 ,+-]+@@$") {
        fix_hunk()
        HUNK_LINE = $0
        HAS_HUNK = 1
    } else if ( HAS_HUNK ) {
        CONTEXT_STR = CONTEXT_STR $0 "\n"

        if ($0 ~ "^+") MODIFY_LINENUM++
        else if ( $0 ~ "^-") {
            MODIFY_LINENUM--
            CONTEXT_LINENUM++
        } else {
            CONTEXT_LINENUM++
        }
    } else {
        print $0
    }
}
END{
    fix_hunk()
}

function fix_hunk(      i, l, startnum){
    if ( ! HAS_HUNK ) return
    l = HUNK_LINE
    l = substr( l, 5 )
    i = index( l, " " )
    l = substr( l, 1, i-1 )
    i = index( l, "," )
    startnum = substr( l, 1, i-1 )

    print "@@ -" startnum "," CONTEXT_LINENUM " +" startnum "," (CONTEXT_LINENUM + MODIFY_LINENUM) " @@"
    print CONTEXT_STR

    CONTEXT_STR = ""
    CONTEXT_LINENUM = 0
    MODIFY_LINENUM = 0
}
