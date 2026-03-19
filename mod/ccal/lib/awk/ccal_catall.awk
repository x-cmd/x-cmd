BEGIN{
    FS = "\t"
}

BEGIN{
    if ( mode == "all") {
        fmt = "%s\033[0m\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t"
        fmt = fmt "\033[31;7m" "%s" "\033[0m" "\t"
        fmt = fmt "\033[0;7m" "%s" "\033[0m"
        fmt = fmt "\n"
    } else {
        fmt = "%s\033[0m %10s %s %s %s "
        fmt = fmt "\033[31;1m" "%s" "\033[0m" "  |  "
        fmt = fmt "\033[0;1;2m" "%s" "\033[0m"
        fmt = fmt "\n"
    }
}

function cat_all(){
    if ($14 == "诸事不宜") {
        printf("\033[32m")
    } else if ($15 == "诸事不忌") {
        printf("\033[31m")
    } else {
        printf("\033[34m")
    }

    gsub(" ", ":", $11)

    gsub(" ", "、", $12)
    gsub(" ", "、", $13)
    printf(fmt, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
}

function cat_part(){
    if ($14 == "诸事不宜") {
        printf("\033[32m")
    } else if (index($15, "诸事不忌") > 0) {
        printf("\033[31m")
    } else {
        printf("\033[34m")
    }

    gsub(" ", ":", $11)

    gsub(" ", "、", $12)
    gsub(" ", "、", $13)
    printf(fmt, $1, $2, $4, $5, $11, $12, $13)
}

{
    if (mode == "all") {
        cat_all()
    } else {
        cat_part()
    }

}
