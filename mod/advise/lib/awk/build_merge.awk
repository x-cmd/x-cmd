BEGIN{
    IS_INDEX_JSON = true;
}

{
    if (IS_INDEX_JSON == true) parse_index_after_tokenize(obj, $0)
    else parse_jsons_after_tokenize(o, $0)
}

#   "<useparam>" --> "#useparam"
function parse_index_after_tokenize( obj, text,       _arr, _arrl, i, j, item, v){
    _arrl = json_split2tokenarr( _arr, text )
    for (i=1; i<=_arrl; ++i) {
        item = _arr[i]
        if ( ( item ~ /^"/) && ( JITER_LAST_KP == "") && ( JITER_STATE == "{")) { #"
            if (item ~ /^"<[^<>]+>"$/) {
                v = juq(item)
                v = substr(v, 2, length(v)-2)
                item = jqu( "#" v )
            }
        }
        jiparse( obj, item )
    }
    if ( JITER_LEVEL != 0 ) return
    JITER_CURLEN = 0
    IS_INDEX_JSON = false
}

function parse_jsons_after_tokenize( o, text ){
    if ( text == X_CMD_ADVISE_ERREXIT ) exit(1)
    jiparse_after_tokenize(_, text)
    if ( JITER_LEVEL != 0 ) return
    cp_merge(o, _)
    delete _ ;  JITER_CURLEN = 0
}

END{
    cp_merge(obj, o)
    print jstr0(obj)
}
