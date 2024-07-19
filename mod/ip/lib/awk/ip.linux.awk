# complete this file according to code file ifconfig.linux.awk parsing ifconfig.linux.txt
# the input data to parse is ip.linux.txt
BEGIN{
    if(NO_COLOR != 1){
        UI_KEY= "\033[36m"
        UI_NUM_VAR= "\033[35m"
        UI_STR_VAR= "\033[32m"
        UI_END= "\033[0m"
    }
}


function handle(            ipv4 ){
    ipv4 = prop[ "inet" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return

    gsub(":$", "", name)
    printf(UI_KEY "%-10s" UI_END "  :  " UI_STR_VAR "%s" UI_END "\n", name, ipv4)
    prop[ "inet" ] = ""
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

END{
    handle()
}
