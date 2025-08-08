

function cres_finishReason( o, prefix ){
    return o[ prefix S "\"finishReason\"" ]
}


function cres_index( o, prefix ){
    return o[ prefix S "\"index\"" ]
}

function cres_role( o, prefix ){
    return o[ prefix S "\"reply\"" S "\"role\"" ]
}

function cres_text( o, prefix ){
    return o[ prefix S "\"reply\"" S "\"parts\"" S "\"1\"" S "\"text\"" ]
}

function cres_dump( o, _kp ){
    return jstr(o, _kp )
}


function cres_load( o,  jsonstr,      _arrl, _arr, i ){
    _arrl = json_split2tokenarr( _arr, jsonstr )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if ( JITER_LEVEL != 0 ) continue
        if ( JITER_CURLEN == HISTORY_SIZE) exit
    }
}



function cres_loadfromjsonfile( o, kp, fp ){
    jiparse2leaf_fromfile( o, kp,  fp )
}


function cres_dump_usage(o, kp,           kp_usage, total_token, obj_usage ){
    kp_usage = kp  SUBSEP "\"usage\""
    if ( o[ kp_usage ] != "{" ) return
    total_token       = int( o[ kp_usage SUBSEP "\"total_tokens\"" ] )
    if ( total_token <= 0 ) return

    jlist_put(obj_usage, "", "{" )
    jdict_put(obj_usage, Q2_1, "\"usage\"", "{" )
    jmerge_force___value( obj_usage, Q2_1 SUBSEP "\"usage\"", o, kp_usage )
    jdict_put(obj_usage, Q2_1 SUBSEP "\"usage\"" SUBSEP "\"usage\"", "\"model\"", o[ kp SUBSEP "\"model\"" ])
    return jstr0( obj_usage, Q2_1, " ")
}

function cres_display_response_usage(o, kp,           kp_usage, total_token, input_token, output_token, model ){
    kp_usage = kp  SUBSEP "\"usage\""
    if ( o[ kp_usage ] != "{" ) return
    total_token       = int( o[ kp_usage SUBSEP "\"total_tokens\"" ] )
    if ( total_token <= 0 ) return
    input_token     = int( o[ kp_usage SUBSEP "\"prompt_tokens\"" ] )
    output_token    = int( o[ kp_usage SUBSEP "\"completion_tokens\"" ] ) + int( o[ kp_usage SUBSEP "\"thought_tokens\"" ] )
    model           = juq( o[ kp SUBSEP "\"model\"" ] )
    title_model     = "Model Usage"

    if ( (kl = (length( title_model ) - length( model ))) >= 0 ) {
        model = model repeat( " ", kl )
    } else {
        title_model = title_model repeat( " ", (0-kl) )
    }

    printf( "\n\n%s %-20s%-20s%-20s\n", title_model, "Input Tokens", "Output Tokens", "Total Tokens")
    print repeat( "─", length(title_model) + 61 )
    printf( "%s %-20s%-20s%-20s\n", model, input_token, output_token, total_token )
}


# gemini_response => cres_object
# openai_response => cres_object
