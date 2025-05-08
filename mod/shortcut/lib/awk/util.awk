
function shortcut_parse_toarr( o, arr, platform,          i, l, q2_word, cmd, oskp, advfp ){
    l = o[ Q2_1 L ]
    for (i=1; i<=l; i++) {
        if ((q2_word = o[ Q2_1, i ]) ~ "^\"<") continue
        shortcut_parse_toarr___inner(o, Q2_1, q2_word, arr, "all")
    }

    oskp = Q2_1 SUBSEP jqu("<" platform ">")
    l = o[ oskp L ]
    for (i=1; i<=l; i++) {
        q2_word = o[ oskp, i ]
        shortcut_parse_toarr___inner(o, oskp, q2_word, arr, platform)
    }
}

function shortcut_parse_toarr___inner(o, kp, q2_word, arr, platform,               word, cmd, advfp, status, category ){
    word = juq(q2_word)
    arr[ word, "\"keypath\"" ] = kp
    arr[ word, "\"q2-word\"" ] = q2_word
    kp = kp SUBSEP q2_word
    if ((cmd = shortcut_getcmd(o, kp)) == "" ) return
    advfp = shortcut_getadvisefp(o, kp)
    status = shortcut_getstatus(o, kp)
    category = shortcut_getcategory(o, kp)

    if (! arr[ word, "\"check\"" ]) arr[ ++arr[ L ], "\"word\"" ] = word
    arr[ word, "\"cmd\"" ] = cmd
    arr[ word, "\"advisefp\"" ] = advfp
    arr[ word, "\"status\"" ] = status
    arr[ word, "\"category\"" ] = category
    arr[ word, "\"advise\"" ] = juq(o[ kp, "\"advise\"" ])
    arr[ word, "\"x-cmd\"" ] = juq(o[ kp, "\"x-cmd\"" ])
    arr[ word, "\"platform\"" ] = platform

    arr[ word, "\"check\"" ] = true
}

function shortcut_remove(o, arr, word,          kp, q2_word){
    kp = arr[ word, "\"keypath\"" ]
    q2_word = arr[ word, "\"q2-word\"" ]
    jdict_rm(o, kp, q2_word)

    kp = kp SUBSEP q2_word
    jdict_rm(o, kp, "\"cmd\"")
    jdict_rm(o, kp, "\"x-cmd\"")
    jdict_rm(o, kp, "\"status\"")
    jdict_rm(o, kp, "\"category\"")
    jdict_rm(o, kp, "\"advise\"")

    word = jqu(q2_word)
    arr[ word, "\"check\"" ] = false
}

function shortcut_getcmd(o, kp,             cmd){
    if (( cmd = o[ kp, "\"x-cmd\"" ] ) != "" ) {
        cmd = "___x_cmd " juq( cmd )
    } else if (( cmd = o[ kp, "\"cmd\"" ] ) != "" ) {
        cmd = juq( cmd )
    }

    gsub( "\n", " ", cmd )
    return str_trim(cmd)
}

function shortcut_getadvisefp(o, kp,             str){
    if ( ( str = o[ kp, "\"advise\"" ] ) != "" ) {
        str = juq( str )
        if (match(str, "^x-advise://")) {
            str = substr( str, RLENGTH+1 )
            if ( str ~ "/" ) return "$___X_CMD_ROOT_ADV/" str
            return "$___X_CMD_ROOT_ADV/" str "/advise.jso"
        }
        else if (match(str, "^x-cmd-advise://")) {
            str = substr( str, RLENGTH+1 )
            if ( str ~ "/" ) return "$___X_CMD_ADVISE_MAN_XCMD_FOLDER/" str
            return "$___X_CMD_ADVISE_MAN_XCMD_FOLDER/" str "/advise.t.jso"
        }
        return str
    }
}

function shortcut_getstatus(o, kp){
    if (o[ kp, "\"status\"" ] == "\"disable\"") return "disable"
    return "enable"
}

function shortcut_getcategory(o, kp){
    category = o[ kp, "\"category\"" ]
    if (( category == "") || ( category == "null") || ( category == "\"\"") ) return ""
    return juq( category )
}

function shortcut_parse_namelist( namearr, namelist,          i, l, _, name, id ){
    l = split(namelist, _, "\n")
    for (i=1; i<=l; ++i){
        name = _[i]
        if (name == "") continue
        id = ++namearr[ L ]
        namearr[ id ] = name
        namearr[ name ] = true
    }
    return id
}

function shortcut_set(o, arr, word, cmd, xcmd, advise, category, platform, status,                       kp, q2_platform, q2_word ){
    if (arr[ word, "\"check\"" ]){
        if (( arr[ word, "\"cmd\"" ] != "" ) && ( (cmd != "") || (xcmd != "") )) {
            log_warn("shortcut", "Shortcut with word '"word"' already exists, it will be overwritten")
            shortcut_remove(o, arr, word)
        }
    } else if ( ! shortcut_check_wordname(word) ) {
        log_error("shortcut", "The shortcut word '"word"' is invalid")
        exit(1)
    }


    kp = Q2_1
    if (( platform != "" ) && ( platform != "all" )){
        q2_platform = jqu( "<" platform ">" )
        shortcut_set_item(o, Q2_1, q2_platform, "{")
        kp = kp SUBSEP q2_platform
    }

    q2_word = jqu(word)
    shortcut_set_item(o, kp, q2_word, "{")

    kp = kp SUBSEP q2_word
    if (cmd != "")      shortcut_set_item(o, kp, "\"cmd\"", jqu(cmd) )
    if (xcmd != "")     shortcut_set_item(o, kp, "\"x-cmd\"", jqu(xcmd) )
    if (advise != "")   shortcut_set_item(o, kp, "\"advise\"", jqu(advise) )
    if (category != "") shortcut_set_item(o, kp, "\"category\"", jqu(category) )

    if (status != "disable") {
        jdict_rm(o, kp, "\"status\"")
    } else {
        shortcut_set_item(o, kp, "\"status\"", jqu(status) )
    }
}

function shortcut_set_item(o, kp, key, val){
    if ( ! jdict_has(o, kp, key) ) jdict_put(o, kp, key, val )
    else o[ kp, key ] = val
}

function shortcut_check_wordname( word ){
    if (( word == "" ) || ( word ~ "^[^a-zA-Z0-9]" )) return false
    return true
}
