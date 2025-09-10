BEGIN {
    FS = "\t"

    ___X_CMD_AUR_TOP_N = ENVIRON[ "___X_CMD_AUR_TOP_N" ]
}

BEGIN {
    fmt_zero    = preppare_fmt( "\033[0;2m" )
    fmt_new     = preppare_fmt( "\033[0;2;36m" )
    fmt_cold    = preppare_fmt( "\033[0;36m" )
    fmt_cool    = preppare_fmt( "\033[0;32m" )
    fmt_warm    = preppare_fmt( "\033[0;33m" )
    fmt_hot     = preppare_fmt( "\033[0;31m" )
    fmt_smoke   = preppare_fmt( "\033[0;1;31m" )
}


function preppare_fmt( pop_fmt,     fmt ){
    fmt = "" # "%s\t"
    fmt = fmt pop_fmt "%7s %s\t"
    fmt = fmt "%6.3f "
    fmt = fmt "%6d "
    fmt = fmt       "%-30s" "\033[0m"       # name
    fmt = fmt "%14s\t"
    fmt = fmt "\033[0;36m" "%s  " "\033[0;2m"

    fmt = fmt "%s "
    fmt = fmt "%s  "
    fmt = fmt "\033[0;31m" "%s  "
    fmt = fmt "\033[0;2m" "%s  "

    fmt = fmt "\033[0;2m" "%s  "
    fmt = fmt "\033[0;2m" "%s  "

    fmt = fmt "%s\n"

    return fmt
}

{
    if (___X_CMD_AUR_TOP_N != "") {
        if ( NR > ___X_CMD_AUR_TOP_N ) exit
    }

    id      = $1
    pop     = $2
    vote    = $3
    name    = $4
    version = $5
    desc    = $6

    _fmt = fmt

    _emo = ""
    if ((pop < 0.001) && (vote == 0) ) {
        _fmt = fmt_zero
        # _emo = "👻"
    } else if ( pop >= 5 ) {
        _fmt = fmt_smoke
        _emo = "⭐"
    } else if ( pop >= 2 ) {
        _fmt = fmt_hot
        _emo = "⭐"
    } else if ( pop >= 1 ) {
        _fmt = fmt_warm
        _emo = "🔥"
    } else if ( pop >= 0.5 ) {
        _fmt = fmt_cool
        _emo = "🌱"
    } else if ( pop >= 0.1 ) {
        _fmt = fmt_cold
    } else {
        _fmt = fmt_new
    }

    outofdate = $7

    maintainer = $8
    submitter = $9

    first = $10
    modified = $11

    url = $12
    baseid= $13
    base = $14
    urlpath = $15

    if (outofdate != "") {
        outofdate = unixepoch_cal_date( outofdate )
    }

    first = unixepoch_cal_date( first )
    modified = unixepoch_cal_date( modified )

    printf( _fmt, id, _emo, pop, vote, name, version, desc, maintainer, submitter, outofdate, first, modified, url, urlpath )
}
