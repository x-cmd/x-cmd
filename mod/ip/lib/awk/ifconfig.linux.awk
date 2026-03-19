
function handle(            ipv4 ){
    ipv4 = prop[ "inet", "addr" ]
    if (ipv4 == "" ) return
    if (ipv4 == "127.0.0.1" ) return
    printf("%10s\t%s\n", name, ipv4)

    delete prop
}

$0~/^[^ \t\v\r]/{
    handle()
    name = $1

    section = $2        # Link
    prop[ section, "type" ] = $3

    if ( $4 == "HWaddr") {
        prop[ section, "mac" ] = $5
    } else if( $4 == "Loopback") {
        prop[ section, "mac" ] = "lo"
    }

    next
}

$1=="inet"{
    gsub(/addr:/, "", $2)
    prop[ "inet", "addr" ] = $2
    gsub(/Mask:/, "", $3)
    prop[ "inet", "mask" ] = $3
    next
}

$1~/^(UP|RX|TX)$/{
    if ($0 ~ "RX bytes"){
        gsub(/bytes:/, "", $2)
        prop[ "rx", "bytes" ] = $2
        gsub(/bytes:/, "", $6)
        prop[ "tx", "bytes" ] = $6
        next
    }

    $1 = lower($1)
    state = ""
    for (i=1; i<=NF; i++) {
        if ($i !~ /:/) {
            state = state $i " "
            continue
        }

        prop[ $1, "state" ] = state

        for (j=i; j<=NF; j++) {
            split($j, a, ":")
            prop[ $1, lower(a[1]) ] = a[2]
            # mtu, metric
        }
        break
    }
    next
}

{
    # collisions, txquenlen
    for (j=i; j<=NF; j++) {
        split($j, a, ":")
        prop[ lower(a[1]) ] = a[2]
    }
}
