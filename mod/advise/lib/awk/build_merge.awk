BEGIN{
    IS_YML_DATA = true;
}

{
    if (IS_YML_DATA == true) parse_yml_data_after_tokenize(obj, $0)
    else parse_jsons_after_tokenize(o, $0)
}

#   "<useparam>" --> "#useparam"
function parse_yml_data_after_tokenize( obj, text,       _arr, _arrl, i, j, item, v){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        item = _arr[i]
        if ( ( item ~ /^"/) && ( JITER_LAST_KP == "") && ( JITER_STATE == "{")) { #"
            if (item ~ /^"<[^<>]+>"$/) {
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

END{
    cp_cover_merge(o, obj)
    print jstr0(o)
}
