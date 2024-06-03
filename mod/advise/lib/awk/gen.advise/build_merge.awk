BEGIN{
    IS_YML_DATA = true;
    Q2_1 = SUBSEP "\"1\""
    Q2_CASE = "\"#case\""
    Q2_TLDR = "\"#tldr\""
    arr_cut( FILTER_FIELD, ENVIRON[ "X_CMD_ADVISE_FILTER_FIELD" ], "\n" )
}

{
    if (IS_YML_DATA == true) parse_yml_data_after_tokenize(obj, $0)
    else parse_jsons_after_tokenize(o, $0)
}

## Section: "<useparam>" --> "#useparam"
function parse_yml_data_after_tokenize( obj, text,       _arr, _arrl, i, j, item, v){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        item = _arr[i]
        if ( ( item ~ "^\"") && ( JITER_LAST_KP == "") && ( JITER_STATE == "{")) {
            if ((item ~ /^"<[^<>]+>"$/) && (JITER_FA_KEYPATH !~ "\"#synopsis\"")) {
                v = juq(item)
                if (v == "<ref>") item = "\"$ref\""
                else item = jqu( "#" substr(v, 2, length(v)-2) )
            }
        }
        jiparse( obj, item )
    }
    if ( JITER_LEVEL != 0 ) return
    JITER_CURLEN = 0
    IS_YML_DATA = false
}

function parse_jsons_after_tokenize( o, text ){
    if ( text == X_CMD_ADVISE_ERREXIT ) exit(1)
    jiparse_after_tokenize(_, text)
    if ( JITER_LEVEL != 0 ) return
    cp_cover_merge(o, _)
    delete _ ;  JITER_CURLEN = 0
}

# EndSection

## Section: parse special fields
function parse_special_fields_value( o, kp,       v ){
    v = o[ kp ]
    if ( v == "{" )         parse_special_fields_dict( o, kp )
    else if ( v == "[" )    parse_special_fields_list( o, kp )
    return
}

function parse_special_fields_dict( o, kp,        i, l, key ){
    l = o[ kp L ]
    for (i=1; i<=l; ++i){
        key = o[ kp, i ]
        if (Q2_CASE == key) parse_case_gpae_tldr_data(o, kp, key)
        else parse_special_fields_value(o, kp SUBSEP key)
    }

    l = FILTER_FIELD[ L ]
    for (i=1; i<=l; ++i) jdict_rm(o, kp, "\"#"FILTER_FIELD[i]"\"")
}

function parse_special_fields_list(o, kp,        i, l){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) parse_special_fields_value(o, kp SUBSEP "\""i"\"")
}

function parse_case_gpae_tldr_data( o, kp, key,     i, l, _kp, _kp_tldr ){
    l = o[ kp, key L ]
    for (i=1; i<=l; ++i){
        _kp = kp SUBSEP key SUBSEP "\""i"\""
        if (o[ _kp, "\"tldr\"" ] == "true"){
            if ( ! jdict_has(o, kp, Q2_TLDR) ) jdict_put(o, kp, Q2_TLDR, "[")
            jlist_put(o, kp SUBSEP Q2_TLDR, "{")
            _kp_tldr = kp SUBSEP Q2_TLDR SUBSEP "\""o[ kp, Q2_TLDR L ]"\""
            jdict_put(o, _kp_tldr, "\"cmd\"", o[ _kp, "\"act\""])
            cp(o, _kp_tldr, o, _kp SUBSEP "\"goal\"")
        }
    }
}

# EndSection

END{
    if (o[L] > 0) {
        cp_cover_merge(o, obj)
        parse_special_fields_value(o, Q2_1)
        print jstr0(o, Q2_1)
        exit(0)
    }
    parse_special_fields_value(obj, Q2_1)
    print jstr0(obj, Q2_1)
}
