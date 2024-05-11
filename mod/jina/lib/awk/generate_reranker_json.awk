BEGIN{
    SEP = ENVIRON[ "sep" ]

    docs  = get_filelist_content()
    model = get_jina_model()
    query = get_query_content()
    top   = get_top_num()

    _data_str = sprintf( "{  \"model\": %s, \"query\": %s, \"documents\": [%s] %s }",  jqu(model), query, docs, top)
    print _data_str
}


function get_filelist_content(       v, i, l, arr, fp, line, j, str, str_l, str_arr, _res ){
    v = ENVIRON[ "filelist" ]
    if(v =="")  return
    l = split( v, arr, ":" )
    for (i=1; i<=l; ++i){
        fp = arr[i]
        if (fp == "") continue

        str = cat(fp)
        if(SEP != ""){
            str_l = split( str, str_arr, SEP )

            for (j=1; j<=str_l; ++j){
                line = str_arr[j]
                if (line == "") continue
                if ( _res != "") _res = _res "," jqu(line)
                else             _res = jqu(line)
            }

        }else{
            if ( _res != "") _res = _res "," jqu(str)
            else             _res = jqu(str)
        }

    }
    return _res
}

function get_query_content(        fp,  _res ){
    fp = ENVIRON[ "query_file" ]
    _res = jqu(cat(fp))
    return _res
}

function get_jina_model( ){
    return  ENVIRON[ "jina_model" ]
}

function get_top_num(        v){
    v = ENVIRON[ "top" ]
    if(v != "") return sprintf( ", \"top_n\": %s" , v )
}

