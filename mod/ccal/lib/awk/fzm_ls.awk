BEGIN{
    FS = "\t"
}

function rep( s, n,     i, r ){
    r = ""
    for (i=1; i<=n; ++i)  r = r s
    return r
}

BEGIN{
    ym = year * 100 + month

    fmt = rep( "%s\t", 3 ) "%s\t\n"
}

{
    split($1, a, "-")
    y = a[1]
    m = a[2]
    cym = y * 100 + m

    if (  cym >= ym )  {
        HIST_STYLE = "\033[0m"
    } else {
        HIST_STYLE = "\033[0;2m"
    }

    if      ((m>=2) && (m<=4))      LEADING = HIST_STYLE "\033[31m"
    else if ((m>=5) && (m<=7))      LEADING = HIST_STYLE "\033[32m"
    else if ((m>=8) && (m<=10))     LEADING = HIST_STYLE "\033[33m"
    else                            LEADING = HIST_STYLE "\033[36m"

    if (m == 12)    LEADING = LEADING "\033[4m"

    if ($3 != "") {
        rest = "\033[36m 🏖️   " $3 " "
    } else {
        rest = ""
    }

    if ($4 != "") {
        gsub("工作", "", $4)
        work = "\033[31m " "调休上班" $4
        # work = "\033[33m 🚀   " $4
        # work = "\033[33m   " $4
    } else {
        work = ""
    }

    printf( LEADING "%s\t%s\t%-40s\n", $1, $2, "\033[0m" HIST_STYLE rest work )
}
