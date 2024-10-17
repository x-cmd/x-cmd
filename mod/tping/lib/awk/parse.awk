
BEGIN{ seq = -1 }

{
    seq ++
    ip          = $1
    port        = $2
    local_ip    = $3
    local_port  = $4

    dns         = $5 * 1000
    con         = $6 * 1000
    time        = con - dns

    if (con == 0)   print_auto( seq, "-1", "-1", "0.0.0.0", "0", "0.0.0.0", "0" )
    else            print_auto( seq, dns, time, local_ip, local_port, ip, port )
}
