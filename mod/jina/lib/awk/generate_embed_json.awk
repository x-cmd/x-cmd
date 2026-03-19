BEGIN{
    content = get_filelist_content()
    model = get_jina_model()
    _data_str = sprintf( "{ \"input\": [%s], \"model\": %s  }", content, jqu(model) )
    print _data_str
}

function get_filelist_content(       v, i, l, arr, fp,  _res ){
    v = ENVIRON[ "filelist" ]
    if(v =="")  return
    l = split( v, arr, ":" )
    for (i=1; i<=l; ++i){
        fp = arr[i]
        if (fp == "") continue
        
        if( i<l ) _res = _res jqu(cat(fp)) ","
        else      _res = _res jqu(cat(fp))
    }
    return _res
}

function get_jina_model( ){
    return  ENVIRON[ "jina_model" ]
}
