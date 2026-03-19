BEGIN{
    FS = "\t"
}

function rep( s, n,     i, r ){
    r = ""
    for (i=1; i<=n; ++i)  r = r s
    return r
}

BEGIN{
    fmt = rep( "%s\t", 7 ) "%s\t\n"
}

{
    if (year <= $1) {
        LEADING = "\033[0m"
    } else {
        LEADING = "\033[0;2m"
    }

    if ($3 == "猪") {
        LEADING = LEADING "\033[4m"
    }

    if ($5 == "") {
        run_yue = ""
    } else {
        run_yue = "\033[31m" "闰 " $5
    }

    printf( LEADING fmt, "\033[36m" $1, "\033[33m" $2, "\033[37m" $3 " " LUNAR_SX_EMO[$3], run_yue, \
        "\033[31m 🧧 "  $6, "\033[35m 🌸 "$7,  "\033[36m 🚣 " $8, "\033[33m 🥮 " $9)
}
