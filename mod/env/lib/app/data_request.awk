{jiparse_after_tokenize( O, $0 )}

END{
    l = split(ARGS, arr, " ")
    _kp = SUBSEP "\"1\""
    for (i=1; i<=l; ++i) _kp = _kp SUBSEP jqu(arr[i])
    l = O[ _kp L ]
    for (i=1; i<=l; ++i){
        key = O[ _kp,  i ]
        insert_info(O, _kp, key)
        print  juq(key) "\003\004" jstr1(O, _kp S key S "\"info\"")
    }
}

function insert_info(O, kp, key){
    if (region != "cn") region = "en"

    desc = O[kp S key S "\"info\"" S "\"desc\"" S "\""region"\"" ]
    if(desc != ""){
        jdict_put(O, kp S key S "\"info\"", "\"desc\"" , desc)
    }else {
        desc = O[kp S "\"desc\"" S "\""region"\"" ]
        jdict_put(O, kp S key S "\"info\"", "\"desc\"" , desc)
    }

    homepage = O[kp S "\"homepage\""]
    if (homepage != "") jdict_put(O, kp S key S "\"info\"", "\"homepage\"" , homepage)

    size = O[kp S key S "\"info\"" S "\"size\"" S "\""os"/"arch"\"" ]
    if (size != "")jdict_put(O, kp S key S "\"info\"", "\"size\"" , size)
    else jdict_put(O, kp S key S "\"info\"", "\"size\"" ,  "\"Unknown\"")

    license = O[kp S "\"license\""]
    if (license != "") jdict_put(O, kp S key S "\"info\"", "\"license\"" , license)
}


