function trim( s ){
    gsub("(^[ \t]+)|([ \t]+)$", "", s)
    return s
}

BEGIN{
    while (getline) {
        result[ l+1, "fp" ] = $0
        if (! getline)    exit
        if (! getline)    exit

        l += 1
        $1 = "";
        result[ l, "sec"    ]   = trim( $0 )

        split(result[l, "sec"], sec_info, "/")
        result[l, "algo"] = sec_info[1]
        result[l, "short_keyid"] = sec_info[2]

        split(result[l, "short_keyid"], sec_info, " ")
        result[l, "short_keyid"] = sec_info[1]
        result[l, "create"] = sec_info[2]
        result[l, "use"] = sec_info[3]
        result[l, "expires"] = sec_info[5]

        split(result[l, "expires"], sec_info, "]")
        result[l, "expires"] = sec_info[1]

        if (! getline)    exit
        result[ l, "keyid"  ]   = trim( $0 )

        if (! getline)    exit
        $1 = "";
        result[ l, "uid"    ]   = trim( $0 )

        if (! getline)    exit
        $1 = "";
        result[ l, "ssb"    ]   = trim( $0 )
    }
}

END {
    fmt = "%s,%s,%s,%s,%s,%s,%s,%s\n"
    printf(fmt, "i", "keyid", "short_keyid", "uid", "expires", "use", "algo", "create")
    for (i=1; i<=l; ++i) {
        printf(fmt, i, result[ i, "keyid"], result[ i, "short_keyid"],result[ i, "uid"], result[ i, "expires"], result[ i, "use"], result[ i, "algo"], result[ i, "create"])
    }
}
