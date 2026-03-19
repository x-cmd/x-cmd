BEGIN{
    VERSION         = ENVIRON[ "version"                ]
    OSARCH          = ENVIRON[ "osarch"                 ]
    region          = ENVIRON[ "___X_CMD_LANG"          ]
    if (( region == "cn" ) || ( region == "zh" )) region = "cn"
    else region = "en"

    pkg_real_name   = ENVIRON[ "pkg_real_name"          ]
    pkg_real_name   = substr(pkg_real_name, index(pkg_real_name,"/") + 1 )
}

{
    jiparse_after_tokenize( O, $0 )
}

END{
    kp = S "\"1\""
    generate_desc_by_region(O, kp)
    if (VERSION == "") generate_lateset_ten_info(O, kp)
    else generate_single_version_info(O, kp, VERSION)

    _[ kp ] = "{"
    _[L] = "1"

    jdict_put(_, kp, "\"pkg\"" , pkg_real_name)
    jdict_put(_, kp, "\"homepage\"" , O[ kp S "\"homepage\""])
    jdict_put(_, kp, "\"license\"" , O[ kp S "\"license\""])
    jdict_put(_, kp, "\"desc\"" , O[ kp S "\"desc\""])
    jdict_put(_, kp, "\"bin\"" , O[ kp S "\"bin\""])

    cp_cover( _, kp , O, kp )
    print jstr(_)
}

function generate_desc_by_region(O, kp,        desc){
    desc = O[ kp S "\"desc\"" S "\""region"\""]
    O[ kp S "\"desc\""] = desc
}

function generate_lateset_ten_info(O, kp,      i, l, count, size, info_kp, _l, j){
    l = O[ kp L ]
    for (i=1; i<=l; ++i) {
        if ((key = juq(O[ kp S i])) !~ "^homepage|^license|^desc"){
            info_kp = kp  SUBSEP "\""key"\"" SUBSEP "\"info\""
            if (O[ info_kp ] != ""){
                ++ count
                O[ kp L ] = i
                generate_size_by_osarch(O, info_kp)
                if(count == 10) break
            }else{
                _l = O[ kp SUBSEP jqu(key) L ]
                for(j=1; j<=_l; ++j){
                    class = O[ kp SUBSEP jqu(key) SUBSEP j ]
                    ++ count
                    O[ kp SUBSEP jqu(key) L ] = j
                    if(count == 10) break
                }
                print jstr1(O, kp SUBSEP jqu(key) )
                exit(1)
            }
        }
    }
}

function generate_single_version_info(O, kp, version,     l, i, _, _kp){
    l = O[ kp L ]
    for (i=1; i<=l; ++i) {
        if ((key = juq(O[ kp S i])) != version){
            if (key ~ "^homepage|^license|^desc" ) continue
            O[ kp S i ] = jqu(version)
            _kp = kp SUBSEP "\""version"\""
            cp_cover( _, kp , O,  kp SUBSEP "\""version"\""  )
            cp_cover( O, _kp , _,  kp )
            O[ kp L ] = i
            break
        }else{
            O[ kp L ] = i
            break
        }
    }
    if (O[kp SUBSEP "\""version"\""] =="") O[kp SUBSEP "\""version"\""] = "NULL"
    info_kp = kp  SUBSEP "\""version"\"" SUBSEP "\"info\""
    generate_size_by_osarch(O, info_kp)
}

function generate_size_by_osarch(O, kp,     size_len){
    size_len = O[ kp S "\"size\"" L ]
    for(k=1; k<=size_len; ++k){
        if( juq(O[ kp S "\"size\"" S k ]) == OSARCH){
            O[ kp S "\"size\"" ] = O[ kp S "\"size\"" S "\""OSARCH"\"" ]
        }
    }
}

