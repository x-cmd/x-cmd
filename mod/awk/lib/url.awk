
# Rely on ord
function urlencode(str,reserve,     a, l, i, o, e, s){
    l = split(str, a, "")
    s = ""
    for (i=1; i<=l; i++) {
        e = a[i]
        o = ord(e)
        # 65-90  :A-Z
        # 97-122 :a-z
        # 48-57  :0-9
        # 95:_ 46:. 33:! 126:~ 42:* 39:' 44:, 45:-

        #  (o ~ /[A-Za-z0-9_.!~*',-]/) {
        if ( (o<=90)&&(o>=65) || (o<=122)&&(o>=97) || (o<=57)&&(o>=48) \
            || ((reserve!="true") && ((o==95) || (o==46) || (o==33) || (o==126) || (o==42) || (o==39) || (o==45))))
                                s = s "" e
        else                    s = s "%" sprintf("%X", o)
    }
    return  s
}

function prepare_url_decode_map(              o, v ){
    URL_DECODER_MAP["111"] = 1

    for (o=1; o<256; ++o) {
        v = sprintf("%c", o)
        if ( (o<=90)&&(o>=65) || (o<=122)&&(o>=97) || (o<=57)&&(o>=48) \
            || (o==95) || (o==46) || (o==33) || (o==126) || (o==42) || (o==39) || (o==44) || (o==45) )
                                URL_DECODER_MAP[ v ] = v
        else if ( o == 32 )     URL_DECODER_MAP["+"] = " "
        else                    URL_DECODER_MAP[ sprintf("%X", o) ] = v
    }
}

function urldecode( str,    l, a, i, s, e, t){
    if (URL_DECODER_MAP["111"] == 0)  prepare_url_decode_map()
    gsub("([A-Za-z0-9_.!~*',+-])|(%[0-9A-Fa-f][0-9A-Fa-f])", "\n&", str)
    l = split( str, a, "\n" )
    for (i=1; i<=l; ++i) {
        e = a[i]
        t = URL_DECODER_MAP[  e  ]

        if (t == "") t = URL_DECODER_MAP[  substr(e, 2)  ]
        s = s t
    }
    return s
}
