{
    jiparse( o, $0 )
}

END{
    if (o[L] == "") jlist_put(o, "", "{")
    kp = SUBSEP jqu(1)
    Q2_PROFILE = jqu("profile")

    if (( current = o[ kp, "\"current\"" ] ) == "") {
        current = "X"
    } else {
        current = juq(current)
    }

    profile = ENVIRON["profile"]
    if (profile == "")  profile = current

    profile_jqu = jqu(profile)

    if (o[ kp, Q2_PROFILE L ] == "") jdict_put(o, kp, Q2_PROFILE, "[")
    kp = kp SUBSEP Q2_PROFILE
    profile_idx = 0
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        if (o[ kp, jqu(i), jqu("name") ] == profile_jqu) {
            profile_idx = i
            break
        }
    }

    if (profile_idx == 0) {
        profile_idx = l = l + 1

        jdict_put( o, kp, jqu(profile_idx), "{")
        jdict_put( o, kp SUBSEP jqu(profile_idx), jqu("name"), profile_jqu )
    }

    kp = kp SUBSEP jqu(profile_idx)

    arr_cut( op, ENVIRON["op"], "\n" )
    for (i=1; i<=op[L]; ++i) {
        str_divide_( op[ i ], "=" )
        key = x_1
        val = x_2
        if ( key != "" ) jdict_put( o, kp, jqu(key), jqu(val) )
    }

    print jstr( o )
}
