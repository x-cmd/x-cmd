BEGIN{
    if(NO_COLOR != 1){
        UI_KEY= "\033[36m"
        UI_NUM_VAR= "\033[35m"
        UI_STR_VAR= "\033[32m"
        UI_END= "\033[0m"
    }
}

function handle(        ipv4 ){
    ipv4 = prop[ "inet" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return

    printf(UI_KEY "%-45s" UI_END "  :  " UI_STR_VAR "%s" UI_END "\n", name, ipv4)
    prop[ "inet" ] = ""
}

$0~/^[^ \t\v\r]/{
    handle()
    gsub(":", "", $0)
    name = $0
    # parse mtu
    next
}

$1=="IPv4"{
    split( $0, arr , ":")
    prop[ "inet" ] = arr[ 2 ]
    next
}

END{
    handle()
}
