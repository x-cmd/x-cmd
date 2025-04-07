BEGIN{
    printf("\n")
}

END {
    printf("\n")
}

{
    if ($0 !~ /^[ \t\v\r]/){
        gsub("(Ethernet[ ]adapter)|(Windows[ ]IP[ ]Configuration)", "\033[32m&\033[0m", $0)
        print "  \033[1;7m" $0 "\033[0m"
        next
    }

    gsub("(disconnected)", "\033[31;1m&\033[0m", $0)
    gsub("^[ \t\v\r]+[A-Za-z0-9 -]+", "\033[36m&\033[0m", $0)

    if ( $0 ~ "[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+") {
        gsub("[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+", "\033[33;1m&\033[0m", $0)
    } else {
        gsub("[0-9a-f]+:[0-9a-f:]+", "\033[34m&\033[0m", $0)
    }

    # gsub("[0-9a-f][0-9a-f][0-9a-f:]+", "\033[34m&\033[0m", $0)
    gsub("[\\. ][\\. ]+", "\033[2m&\033[0m", $0)

    gsub("(No|Disabled)($)", "\033[31;1m&\033[0m", $0)
    gsub("(Yes|Enabled)($)", "\033[32;1m&\033[0m", $0)
    print "  " $0
}
