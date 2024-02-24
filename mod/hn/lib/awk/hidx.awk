{ jiparse_after_tokenize(o, $0); }
END{
    l = o[ L ]
    for (i=1; i<=l; ++i){
        _kp = SUBSEP "\""i"\""
        # debug( o[ _kp, "\"type\""] )
        if ( (o[ _kp, "\"type\""] == "\"story\"")   \
            && (o[ _kp, "\"deleted\""] != "true")   \
            && (o[ _kp, "\"dead\""] != "true") )    \
            score[ ++scorel ] = int(o[ _kp, "\"score\""])
    }
    score[L] = scorel
    arr_qsort( score )
    for (i=0; i<scorel; i++){
        if (score[scorel-i] > i) hidx++
    }
    print sh_varset_val( "_hidx", int(hidx) )
}
