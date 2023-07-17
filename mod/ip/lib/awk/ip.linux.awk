# complete this file according to code file ifconfig.linux.awk parsing ifconfig.linux.txt
# the input data to parse is ip.linux.txt


function handle(            ipv4 ){
    ipv4 = prop[ "inet" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return
    printf("%10s\t%s\n", name, ipv4)
}

$0~/^[^ \t\v\r]/{
    handle()
    name = $2
    # parse mtu
    next
}

{
    for (i=1; i<=NF; ++i) {
        j = i; i += 1
        prop[ $j ] = $i
    }
}


