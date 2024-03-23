
function llmf_parse_args(name, arr,      l, _, q){
    l = split(name, _, "/")

    arr[ L ] = l = arr[ L ] + 1
    arr[ l, "NAME" ] = _[1]
    arr[ l, "VERSION" ] = _[2]
    q = _[3]
    sub("\\..+$", "", q)
    arr[ l, "QUANT" ]   = q
    return _[1]
}

function llmf_parse_json(o, obj,            l, i, name, kp, v, q  ){
    obj[ L ] = 1
    obj[ Q2_1 ] = "{"

    l = ARR[ L ]
    for (i=1; i<=l; ++i){
        name = jqu(ARR[ i, "NAME" ])
        kp = Q2_1 SUBSEP name
        if (o[ kp L ] <=0 ) continue
        jdict_put(obj, Q2_1, name, "{")

        v = ARR[i, "VERSION"]
        if (v == ""){
            cp(obj, kp, o, kp)
        } else {
            v = jqu(v)
            if (o[ kp, v L ] <=0 ) continue
            q = ARR[i, "QUANT"]
            jdict_put(obj, kp, v, "{")
            if (q == "") {
                cp(obj, kp SUBSEP v, o, kp SUBSEP v)
            } else {
                q = jqu(q)
                if (o[ kp, v, q L ] <=0 ) continue
                jdict_put(obj, kp SUBSEP v, q, "{")
                cp(obj, kp SUBSEP v SUBSEP q, o, kp SUBSEP v SUBSEP q)
            }
        }
    }
}

BEGIN{
    Q2_1 = SUBSEP "\"1\""
    o[ L ] = 1
    o[ Q2_1 ] = "{"
}
{
    name = $0
    sub("\\.json$", "", name)
    name = llmf_parse_args(name, ARR)
    jdict_put(o, Q2_1, jqu(name), "{")
    jiparse2leaf_fromfile( o, Q2_1 SUBSEP jqu(name),  dirpath "/" name ".json" )
}
END{
    llmf_parse_json(o, obj)
    print jstr(obj)
}

