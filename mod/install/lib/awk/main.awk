
BEGIN{
    patarr[1] = "\"[0-9]+\""
    patarrl = 1
    GET_NAME = 0
}

$0 == "+++"{
    GET_NAME = 1
    next
}

GET_NAME == 1{
    install_name = $0
    GET_NAME = 0
    next
}


GET_NAME == 0{

    if ($0 == "") next
    obj_arrl = json_split2tokenarr( obj, $0 )
    for (_i=1; _i<=obj_arrl; ++_i) {
        if ( jiter_regexarr_parse( O, obj[_i], patarrl, patarr ) == true ){
            # print jstr(O)
            get_install_cmd(O)
            delete O
        }
    }
}


