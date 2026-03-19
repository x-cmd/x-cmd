BEGIN{
    print
}

END {
    print
}

{
    if ($0~/^[ \t\v\r]/){
        if ($0 ~ /inet6/) {
            gsub("(inet6)|(prefixlen)|(scopeid)", "\033[34;2m&\033[0m", $0)
            gsub("0x[0-9a-f]+", "\033[33m&\033[0m", $0)
            gsub("[0-9a-f][0-9a-f][0-9a-f:]+", "\033[34m&\033[0m", $0)
        } else if ($0 ~ /inet/) {
            gsub("[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+", "\033[33;1m&\033[0m", $0)
            gsub("0x[0-9a-f]+", "\033[33m&\033[0m", $0)
            gsub("(inet)|(netmask)", "\033[32;2m&\033[0m", $0)
        } else if ($0 ~ /ether/) {
            gsub("(ether)", "\033[34;2m&\033[0m", $0)
            gsub("[0-9a-f][0-9a-f][0-9a-f:]+", "\033[34m&\033[0m", $0)
        } else if ($0 ~ /status:/) {
            if ($0 ~ /inactive/) {
                # gsub("(inactive)", "\033[31m&\033[0m", $0)
                $0 = "\033[31;7m" $0 "\033[0m"
            } else {
                # gsub("(active)", "\033[34;1m&\033[0m", $0)
                $0 = "\033[32;7;1m" $0 "\033[0m"
            }
        } else {
            gsub("(ether)|(nd6)|(options=)|(media:)|(status:)", \
                "\033[32;2m&\033[0m", $0)
            gsub("(inactive)", "\033[31m&\033[0m", $0)
            gsub("[A-Z][A-Z0-9_]+", "\033[36m&\033[0m", $0)
        }
        print "    " $0
    } else {
        gsub("[0-9][0-9]+", "\033[34m&\033[0m", $0)
        gsub("^[^: ]+:", "\033[34;7m&\033[0m", $0)
        gsub("(flags=)|(mtu)", "\033[32;2m&\033[0m", $0)
        gsub("[A-Z][A-Z0-9_]+", "\033[36m&\033[0m", $0)
        gsub("(DOWN)", "\033[31m&\033[0m", $0)
        gsub("(UP)|(RUNNING)", "\033[32m&\033[0m", $0)

        print "    " $0
    }

}
