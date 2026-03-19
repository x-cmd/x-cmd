
# for both win and busybox

NR==1{
    if (input == "win") {
        VENDOR = "win"
    } else {
        if ($0 ~ /:$/)   VENDOR = "win"
    }

    # TODO: Parse the first line and output the meta data
    next
}

NR==2{
    if ($0 ~ /:$/) {
        VENDOR = "win"
        next
    }
}

{
    if (VENDOR == "win")        parse_win_ping()
    else                        parse_busybox_ping()
}

function parse_busybox_ping(){
    if ($0 ~ /(timeout|no answer)/) {
        print_auto( trim_key( $NF ), 0, -1, "0.0.0.0", -1 )
        return
    }
    if ($0 !~ /ttl=/)           return

    byte = $1
    ip = $4
    gsub( /:$/, "", ip )
    # ... Find out the diffs ...
    seq         = trim_key( $(NF-3) )
    ttl         = trim_key( $(NF-2) )
    time        = trim_key( $(NF-1) )

    print_auto( seq++, byte, ttl, ip, time )
}

function parse_win_ping(){
    if ($0 ~ /timed out/) {
        print_auto( seq++, 0, -1, "0.0.0.0", -1 )
        return
    }
    if ($0 !~ /TTL=/)       return

    if ( $0 ~ /Reply/ )     ip = $3
    else                    ip = $2

    gsub( /:$/, "", ip )
    byte        = trim_key( $(NF-2) )
    time        = trim_key( $(NF-1) )
    ttl         = trim_key( $NF )

    print_auto( seq++, byte, ttl, ip, time )
}
