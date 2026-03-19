
function preppare_fmt_colr( fmt ){
    fmt = "" # "%s\t"
    fmt = fmt      indent "\033[0;36m" "id           :   %s"
    fmt = fmt "\n" indent "\033[0;33m" "popularity   :   %f"
    fmt = fmt "\n" indent "\033[0;33m" "vote         :   %d"
    fmt = fmt "\n" indent "\033[0;36m" "name         :   %s"
    fmt = fmt "\n" indent "\033[0;36m" "version      :   %s"
    fmt = fmt "\n" indent "\033[0;32m" "desc         :   %s"

    fmt = fmt "\n" indent "\033[0;36m" "submitter    :   %s"
    fmt = fmt "\n" indent "\033[0;36m" "maintainer   :   %s"

    fmt = fmt "\n" indent "\033[0;33m" "first-submit :   %s"
    fmt = fmt "\n" indent "\033[0;35m" "modified     :   %s"
    fmt = fmt "\n" indent "\033[0;31m" "out-of-date  :   %s"

    fmt = fmt "\n" indent "\033[0;33m" "url          :   %s"
    fmt = fmt "\n" indent "\033[0;36m" "urlpath      :   %s"

    fmt = fmt "\n" indent "\033[0;36m" "base         :   %s"
    fmt = fmt "\n" indent "\033[0;36m" "baseid       :   %s"

    fmt = fmt "\n"
    return fmt
}

function preppare_fmt( fmt ){
    fmt = "" # "%s\t"
    fmt = fmt      indent "id           :   %s"
    fmt = fmt "\n" indent "popularity   :   %f"
    fmt = fmt "\n" indent "vote         :   %d"
    fmt = fmt "\n" indent "name         :   %s"
    fmt = fmt "\n" indent "version      :   %s"
    fmt = fmt "\n" indent "desc         :   %s"

    fmt = fmt "\n" indent "submitter    :   %s"
    fmt = fmt "\n" indent "maintainer   :   %s"

    fmt = fmt "\n" indent "first-submit :   %s"
    fmt = fmt "\n" indent "modified     :   %s"
    fmt = fmt "\n" indent "out-of-date  :   %s"

    fmt = fmt "\n" indent "url          :   %s"
    fmt = fmt "\n" indent "urlpath      :   %s"

    fmt = fmt "\n" indent "base         :   %s"
    fmt = fmt "\n" indent "baseid       :   %s"

    fmt = fmt "\n"
    return fmt
}

BEGIN{
    FS = "\t"
    # fmt = preppare_fmt()

    indent = ENVIRON["___X_CMD_CUR_INFO_INDENT"]

    colr_enable = ENVIRON["___X_CMD_CUR_INFO_COLR"]

    if (colr_enable != "") {
        fmt = preppare_fmt_colr()
    } else {
        fmt = preppare_fmt()
    }
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

    if ( (id      != KEYWORD) && (name    != KEYWORD) )  next

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

    printf( fmt, id, pop, vote, name, version, desc, maintainer, submitter, first, modified, outofdate, url, urlpath, base, baseid )

    exit
}

