function handle(        ipv4 ){
    ipv4 = prop[ "inet" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return
    printf("%-45s\t%s%s\n", name, ":", ipv4)
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
