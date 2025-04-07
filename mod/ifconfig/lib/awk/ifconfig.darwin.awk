BEGIN{
    if(NO_COLOR != 1){
        UI_KEY= "\033[36m"
        UI_NUM_VAR= "\033[35m"
        UI_STR_VAR= "\033[32m"
        UI_END= "\033[0m"
    }

    output_tsv_header()
}

function output(            ipv4 ){
    ipv4 = prop[ "inet" ]
    # if (ipv4 == "" ) return
    # if (ipv4 == "127.0.0.1" ) return

    gsub(":$", "", name)
    printf(UI_KEY "%-10s" UI_END "  :  " UI_STR_VAR "%s\t%s" UI_END "\n", name, ipv4, prop[ "mac" ])
    delete prop
}

function output_tsv_header(){
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
        "name", "ether", "inet", "inet6", "mtu", "status", "media", "option", "state", "nd6_option")

}

function output_tsv(){
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
        name, prop["ether"], prop["inet"], prop["inet6"], prop["mtu"], prop["status"], prop["media"], prop["option"], prop["state"], prop["nd6_option"])
}

BEGIN{
    first = ""
}

$0~/^[^ \t\v\r]/{
    if (first)  {
        output_tsv()
        delete prop
    }
    first = 1

    name = $1

    gsub(/flags=/, "", $2)
    prop[ "flags" ] = int($2)
    gsub(/^[^<]+/, "", $2)
    prop[ "state" ] = substr($2, 2, length($2) - 2)
    prop[ "mtu" ] = int($4)
    # parse mtu
    next
}

{
    for (i=1; i<=NF; ++i) {
        j = i; i += 1

        if ($j == "ether") {
            prop[ "ether" ] = $i
        } else if ($j ~ /^options=/) {
            prop[ "option" ] = substr( $j, 9 )
        } else if ($j ~ /^(media|status):/){
            prop[ substr($j, 1, length($j)-1) ] = $i
        } else if ($j ~ /^(nd6[ ]options=)/){
            prop[ "nd6_option" ] = substr( $j, 11 )
        } else {
            prop[ $j ] = $i
        }
    }
}

END{
    output_tsv()
}
