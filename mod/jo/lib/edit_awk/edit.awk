{
    jiparse_after_tokenize(o, $0)
}

function jkey_( k,          a, i, l ){
    l = split(k, a, ".")
    x_1 = ""
    if (a[1] == "") a[1] = "1"
    for (i=1; i<=l-1; ++i) {
        x_1 = x_1 SUBSEP jqu(a[i])
    }
    x_2 = jqu(a[l])
}

END{
    arr_cut( op, ENVIRON["op"], "\n" )

    for (i=1; i<=op[L]; ++i) {
        str_divide_( op[ i ], "=" )
        key = x_1
        val = x_2

        jkey_( key )
        jdict_put( o, x_1, x_2, val )
    }

    print jstr( o )
}
