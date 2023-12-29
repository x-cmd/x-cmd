

# req.chat.json
# res.chat.json

# req.gemini.json
# res.gemini.json

# req.openai.json
# res.openai.json

function creq_minion( o, prefix ){
    return o[ prefix S "\"minion\"" ]
}

function creq_question( o, prefix ){
    return o[ prefix S "\"question\"" ]
}

function creq_history_num( o, prefix ){
    return o[ prefix S "\"history_num\"" ]
}

function creq_chaid( o, prefix ){
    return o[ prefix S "\"chaid\"" ]
}
function creq_model( o, prefix ){
    return o[ prefix S "\"model\"" ]
}

function creq_history_message( o, prefix ){
    return o[ prefix S "\"model\"" ]
}


function creq_load( o,  jsonstr,      _arrl, _arr, i ){
    _arrl = json_split2tokenarr( _arr, jsonstr )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == HISTORY_SIZE) exit
    }
}



function creq_loadfromjsonfile( o, kp, fp ){
    jiparse2leaf_fromfile( o, kp,  fp )
}

function creq_create( o, minion_obj, minion_kp, model, question, chatid, history_num, history_message,       _kp){
    _kp = SUBSEP "\""1"\""

    jlist_put(o,  "" , "{")
    jdict_put(o, _kp, "\"minion\"",          "{")
    jdict_put(o, _kp, "\"model\"",           jqu(model))
    jdict_put(o, _kp, "\"question\"",        jqu(question))
    jdict_put(o, _kp, "\"chatid\"",          jqu(chatid))
    jdict_put(o, _kp, "\"history_num\"",     history_num)
    cp_cover(o, _kp SUBSEP "\"minion\"", minion_obj, minion_kp)
}

function creq_dump( o,  _kp ){
    return  jstr( o, _kp )

}

# function creq_json_file_create(obj, fildedir, MINION, model, QUESTION, CHATID, HISTORY_NUM ){
#     creq_create(obj, MINION, model, QUESTION, CHATID, HISTORY_NUM  )
#     print creq_dump(obj) > SESSIONDIR "/" CHATID "/req.json" > fildedir "/req.json"
# }
# req => gemini_request
# req => openai_request

