
function cfgy_obj_current_get( o, rootkp ){
    return o[ rootkp, "\"current\"" ]
}

function cfgy_obj_current_set( o, rootkp, val ){
    o[ rootkp, "\"current\"" ] = val
}
