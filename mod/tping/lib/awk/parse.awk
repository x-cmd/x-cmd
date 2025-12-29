
BEGIN{ seq = -1 }

$0~/^SSH/{
    next
}

{
    seq ++

    ts          = $1

    ip          = $2
    port        = $3
    local_ip    = $4
    local_port  = $5

    dns         = $6 * 1000
    con         = $7 * 1000
    time        = con - dns

    if (con == 0)   print_auto( ts, seq, "-1", "-1", "0.0.0.0", "0", "0.0.0.0", "0" )
    else            print_auto( ts, seq, dns, time, local_ip, local_port, ip, port )
}
