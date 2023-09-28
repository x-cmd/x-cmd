BEGIN{
    L = "\001"
}

{
    if (match($0, /^[A-Za-z0-9_]+=/)) {
        l = ++ a[ type L ]
        a[ type, l, "K" ] = substr($0, 1, RLENGTH - 1)
        a[ type, l, "V" ] = substr($0, RLENGTH + 1)
    } else {
        if (t[ type=$1 ])     next
        l = t[ type ] = (++t[ L ])
        t[ "DATA" l ] = type
    }
}

END{
    for (i = 1; i <= t[ L ]; ++i) {
        type = t[ "DATA" i ]
        printf "%-10s\t%10s\n", type, ENVIRON[ type ]

        for (j=1; j <= a[ type L ]; ++j) {
            printf "    %-20s    %s\n", a[ type, j, "K" ], a[ type, j, "V" ]
        }
    }
}
