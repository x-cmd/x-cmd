

NR==1{
    next
}

$0~/(timeout|no answer)/{
    print_auto( trim_key( $NF ), 0, -1, "0.0.0.0", -1 )
    next
}

$0~/ttl=/{
    byte = $1
    ip = $4
    gsub( ":", "", ip )

    # ... Find out the diffs ...
    seq         = trim_key( $(NF-3) )
    ttl         = trim_key( $(NF-2) )
    time        = trim_key( $(NF-1) )

    print_auto( seq++, byte, ttl, ip, time )
}



# TODO: parse the timeout log
