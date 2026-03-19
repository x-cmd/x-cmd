BEGIN{
    printf("\n")
}

END {
    printf("\n")
}

{
    if ($0 !~ /^[ \t\v\r]/){
        gsub("([^:]+:)|(mtu)|(qdisc)|(state)|(group)|(qlen)", "\033[34m&\033[0m", $0)
        gsub("[A-Z][A-Z0-9_]+", "\033[32m&\033[0m", $0)
        print "  \033[1;7m" $0 "\033[0m"
        next
    }

    gsub("^[ \t\v\r]+[A-Za-z0-9]+", "\033[36m&\033[0m", $0)

    if ( $0 ~ "[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+") {
        gsub("[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+", "\033[33;1m&\033[0m", $0)
    } else {
        gsub("[0-9a-f]+:[0-9a-f:]+", "\033[34m&\033[0m", $0)
    }

    gsub("(inet6)|(inet)|(brd)|(scope)|(link.ether)|(valid_lft)|(preferred_lft)", "\033[32;2m&\033[0m", $0)

    print "  " $0
}
