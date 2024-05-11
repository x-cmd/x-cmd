BEGIN{
    X_TERM_MIN  = int(ENVIRON[ "X_TERM_MIN" ])
    X_TERM_MAX  = int(ENVIRON[ "X_TERM_MAX" ])
    X_TERM_STEP = int(ENVIRON[ "X_TERM_STEP" ])

    X_TERM_MIN  = (X_TERM_MIN != "") ? X_TERM_MIN : 80
    X_TERM_MAX  = (X_TERM_MAX != "") ? X_TERM_MAX : 255
    X_TERM_STEP = (X_TERM_STEP != "") ? X_TERM_STEP : 10

    X_TERM_parrl  = rainbow_generate_pallete( parr, X_TERM_MIN, X_TERM_MAX, X_TERM_STEP )
    X_TERM_parrstart = 1

}

{
    if ( (X_TERM_parrstart += 3) > X_TERM_parrl) X_TERM_parrstart = 1

    _cl = split(trim033($0), _chararr, "")
    r = ""
    _pi = X_TERM_parrstart
    for (j=1; j<=_cl; ++j) {
        c = _chararr[j]

        if (X_THRM_utf8_l <= 0) {
            X_THRM_char_buffer = c
            X_THRM_utf8_l = ord_leading1( ord(c) )
            if ( X_THRM_utf8_l != 0 ){
                X_THRM_utf8_l --
                continue
            }
        } else {
            X_THRM_char_buffer = X_THRM_char_buffer c
            X_THRM_utf8_l --
            if (X_THRM_utf8_l != 0) continue
        }

        r = r parr[ _pi ] X_THRM_char_buffer
        if ( (_pi += 1) > X_TERM_parrl ) _pi = 1
        X_THRM_char_buffer = ""
    }

    printf( "%s\n", r "\033[0m" )
    fflush()
}
