BEGIN{
    Q2_1    = "\"1\""
    Q2_XRC  = "\"xrc\""
    Q2_REPLACE_LIST = "\"replace-list\""
}
function get_cur_dir(file,     dir_path){
    if (match(file, "/[^/]+$")) dir_path = substr(file, 1, RSTART-1)
    return dir_path
}

function get_fullpath(file,             suf, pre){
    while( match(file, "/\\.\\./")){
        suf = substr(file, RSTART + RLENGTH)
        pre = substr(file, 1, RSTART-1)
        pre = get_cur_dir(pre)
        file = pre "/" suf
    }
    return file
}

function get_obj_of_yxrc(o, file,        obj, v, kp, dir_path, _filepath, _content){
    _content = cat( file )
    if ( cat_is_filenotfound() ) {
        log_error("apply/xrc", "Not found file " file)
        exit 1
    }
    yml_parse( _content, obj )
    jmerge_force(o, obj)

    kp = SUBSEP Q2_1
    v = juq(o[ kp , Q2_XRC ])
    if ( v == "" ) return
    sub("^\\./", "", v)
    jdict_rm(o, kp, Q2_XRC)
    delete o[ kp, Q2_XRC ]

    dir_path = get_cur_dir(file)
    _filepath = get_fullpath( dir_path "/" v )
    get_obj_of_yxrc(o, _filepath)
}

{   get_obj_of_yxrc(_, $0); print jstr0(_);   }


