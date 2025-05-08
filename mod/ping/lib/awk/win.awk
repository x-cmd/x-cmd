# TODO:  Recognizing timeouts in different languages
$0~/timed out/{
    print_auto( seq++, 0, -1, "0.0.0.0", -1 )
    next
}

$0~/TTL=/{
    if ( $0 ~ /Reply/ )     ip = $3
    else                    ip = $2

    gsub( /:$/, "", ip )
    byte        = trim_key( $(NF-2) )
    time        = trim_key( $(NF-1) )
    ttl         = trim_key( $NF )

    print_auto( seq++, byte, ttl, ip, time )

    next
}

$0~/time=[^$]+$/{
    ip          = $(NF-1)
    gsub( /:$/, "", ip )
    time        = trim_key( $(NF) )
    print_auto( seq++, 0, 0, ip, time )
}

$0~/Request[ ]timed[ ]out/{
    print_auto( seq++, 0, -1, "0.0.0.0", -1 )
}
