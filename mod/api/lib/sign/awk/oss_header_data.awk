{
    jiparse_after_tokenize(o, $0)
}

END{
    Q2_1 = S "\"1\""
    l = o[ Q2_1 L ]
    for (i=1; i<=l; ++i) {
        k = o[ Q2_1, i ]
        if (k ~ "^\"x_oss") {
            key = juq(k)
            gsub("_", "-", key)
            h_str =  ( h_str == "" ) ? key ":" o[ Q2_1, k ] "\n" : h_str key ":" o[ Q2_1, k ] "\n"
            _key[i] = k
        }else if ( method == "GET" ) {
            val = o[ Q2_1, k ]
            gsub("_", "-", k)
            data = ( data == "" ) ? "--data-urlencode " juq(k) "=" val  : data " --data-urlencode " juq(k) "=" val
            print "ali_json_data=" str_quote2(data)
        }
    }

    if ( method == "POST" || method == "PUT" ){
        len = length(_key)
        for (i=1; i<=len; ++i)  jdict_rm( o, Q2_1, _key[i] )
        print "ali_json_data=" qu1(jstr(o))
    }
    print "oss_headers=" str_wrap2(h_str)
}
