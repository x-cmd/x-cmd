{
    l = json_split2tokenarr( O , $0 )
    for (i=1; i<=l; ++i) {
        t = O[i]
        if (t != "") print t
    }
}