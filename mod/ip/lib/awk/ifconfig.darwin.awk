
function handle(            ipv4 ){
    ipv4 = prop[ "inet" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return
    printf("%10s\t%s\n", name, ipv4)
}

$0~/^[^ \t\v\r]/{
    handle()
    name = $1

    gsub(/flags=/, "", $2)
    prop[ "flags" ] = int($2)
    gsub(/^[^<]+/, "", $2)
    prop[ "flags-state" ] = substr($2, 2, length($2) - 2)
    prop[ "mtu" ] = int($4)
    # parse mtu
    next
}

{
    for (i=1; i<=NF; ++i) {
        j = i; i += 1

        if ($j == "ether") {
            prop[ "mac" ] = $i
        } else if ($j ~ /^(media|status):/){
            prop[ substr($j, 1, length($j)-1) ] = $i
        } else {
            prop[ $j ] = $i
        }
    }
}

END{
    handle()
}
