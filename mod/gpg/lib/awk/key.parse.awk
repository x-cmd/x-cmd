function trim( s ){
    gsub("(^[ \t]+)|([ \t]+)$", "", s)
    return s
}

BEGIN{
    l = 0
    while (getline) {
        if ($1 == "pub") {
            l += 1
            result[ l+1, "fp" ] = $0
            $1 = "";
            result[ l, "pub"    ]   = trim( $0 )

            split(result[l, "pub"], pub_info, "/")
            result[l, "algo"] = pub_info[1]
            result[l, "short_keyid"] = pub_info[2]

            split(result[l, "short_keyid"], pub_info, " ")
            result[l, "short_keyid"] = pub_info[1]
            result[l, "create"] = pub_info[2]
            result[l, "use"] = pub_info[3]
            result[l, "expires"] = pub_info[5]

            split(result[l, "expires"], pub_info, "]")
            result[l, "expires"] = pub_info[1]

            if (! getline)    exit
            result[ l, "keyid"  ]   = trim( $0 )

            if (! getline)    exit
            $1 = "";
            result[ l, "uid"    ]   = trim( $0 )

            if (! getline)    exit
            $1 = "";
            result[ l, "sub"    ]   = trim( $0 )
        }
    }
}

END {
    fmt = "%s,%s,%s,%s,%s,%s,%s,%s\n"
    printf(fmt, "i", "keyid", "short_keyid", "uid", "expires", "use", "algo", "create")
    for (i=1; i<=l; ++i) {
        printf(fmt, i, result[ i, "keyid"], result[ i, "short_keyid"],result[ i, "uid"], result[ i, "expires"], result[ i, "use"], result[ i, "algo"], result[ i, "create"])
    }
}
