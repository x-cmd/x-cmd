NR==1{
    if (col ~ "^(auto|-)$") {
        col = NF
    }
}

{
    for (i=1; i<int(col); ++i) {
        e = $i
        gsub("(^[ ]+)|([ ]+$)", "", e)
        printf("%s,", csv_quote_ifmust(e))
        $i=""
    }
    e = $0
    gsub("(^[ ]+)|([ ]+$)", "", e)
    printf("%s\n", csv_quote_ifmust(e))
}
