function rainbow_text( linearr, rainbowlinearr, parr, start, end, step,
    i, j, l, r, c, _c_utf8_l, _c_buffer, _parrstart, _parrl, _cl, _line, _chararr ){

    # step 1 ->     generate pallete
    start   = ( start != "" )   ? start : 80
    end     = ( end != "" )     ? end   : 255
    step    = ( step != "" )    ? step  : 10
    _parrl  = rainbow_generate_pallete( parr, start, end, step )

    rainbowlinearr[ L ] = l = linearr[ L ]

    _parrstart = 1

    for (i=1; i<=l; ++i) {
        _line = linearr[i]

        if ( (_parrstart += 3) > _parrl)    _parrstart = 1

        # step 2 ->     tokenized
        _cl = split(_line, _chararr, "")
        r = ""
        # step 3 ->     paint
        _pi = _parrstart
        for (j=1; j<=_cl; ++j) {
            c = _chararr[j]

            if (_c_utf8_l <= 0) {
                _c_buffer = c
                _c_utf8_l = ord_leading1( ord(c) )
                if ( _c_utf8_l != 0 ){
                    _c_utf8_l --
                    continue
                }
            } else {
                _c_buffer = _c_buffer c
                _c_utf8_l --
                if (_c_utf8_l != 0) continue
            }

            r = r parr[ _pi ] _c_buffer
            if ( (_pi += 1) > _parrl )      _pi = 1
            _c_buffer = ""
        }

        rainbowlinearr[i] = r "\033[0m"
    }
}

# default, 80, 255, 10/30
function rainbow_generate_pallete( parr, start, end, step,          i, l, r, g, b ) {
    l = parr[ L ] = 0
    colr_rgb_init( COLR_RGB, start, end )
    for (i=start; i<=end; i++) {
        colr_rgb( COLR_RGB , step )
        r = COLR_RGB["R"]
        g = COLR_RGB["G"]
        b = COLR_RGB["B"]
        parr[ (++l) ] = (X_TERM_COLORS == "true") ? colr_rgbtotrue( r, g, b ) : colr_rgbto256( r, g, b )
    }

    # revere the pallete
    for (i=l; i>=1; --i) {
        parr[ (++l) ] = parr[i]
    }
    parr[ L ] = l

    return l
}

BEGIN{
    COLR_RGB_256_CACHE[ 1 ] = 0
    X_TERM_COLORS = ENVIRON[ "X_TERM_COLORS" ]
    X_TERM_SRAND = ENVIRON[ "X_TERM_SRAND" ]
}

function colr_rgb_init(COLR_RGB, min, max,      i, l ){
    COLR_RGB["S"] = "G+"
    COLR_RGB["R"] = max
    COLR_RGB["G"] = min
    COLR_RGB["B"] = min
    COLR_RGB["MAX"] = max
    COLR_RGB["MIN"] = min

    if ( X_TERM_SRAND != "" ) {
        srand( X_TERM_SRAND )
        l = int (rand() * 100 )
        for (i=1; i<=l; ++i){
            colr_rgb(COLR_RGB, 16)
        }
    }
}

function colr_rgb(COLR_RGB, step,         max, min){
    max = COLR_RGB["MAX"]
    min = COLR_RGB["MIN"]
    if ( COLR_RGB["S"] == "G+" ) {
        COLR_RGB["G"] += step
        if ( COLR_RGB["G"] > max ) {
            COLR_RGB["G"] = max
            COLR_RGB["S"] = "R-"
        }
    } else if ( COLR_RGB["S"] == "R-" ) {
        COLR_RGB["R"] -= step
        if ( COLR_RGB["R"] < min ) {
            COLR_RGB["R"] = min
            COLR_RGB["S"] = "B+"
        }
    } else if ( COLR_RGB["S"] == "B+" ) {
        COLR_RGB["B"] += step
        if ( COLR_RGB["B"] > max ) {
            COLR_RGB["B"] = max
            COLR_RGB["S"] = "G-"
        }
    } else if ( COLR_RGB["S"] == "G-" ) {
        COLR_RGB["G"] -= step
        if ( COLR_RGB["G"] < min ) {
            COLR_RGB["G"] = min
            COLR_RGB["S"] = "R+"
        }
    } else if ( COLR_RGB["S"] == "R+" ) {
        COLR_RGB["R"] += step
        if ( COLR_RGB["R"] > max ) {
            COLR_RGB["R"] = max
            COLR_RGB["S"] = "B-"
        }
    } else if ( COLR_RGB["S"] == "B-" ) {
        COLR_RGB["B"] -= step
        if ( COLR_RGB["B"] < min ) {
            COLR_RGB["B"] = min
            COLR_RGB["S"] = "G+"
        }
    }
}

function colr_rgbtotrue( r, g, b ){
    return sprintf( "\033[38;2;%d;%d;%dm", r, g, b )
}

function colr_rgbto256( r, g, b,            e ){
    if ( (e = COLR_RGB_256_CACHE[ r, g, b ]) == "" ) {
        e = COLR_RGB_256_CACHE[ r, g, b ] = "\033[38;5;" (16 + 36 * int(r/45) + 6 * int(g/45) + int(b/45)) "m"
    }
    return e
}

