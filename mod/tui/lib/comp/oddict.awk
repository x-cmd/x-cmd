
# compatible with json dict structure

function oddict_get_defined_by_user( o, kp, k ){
    return false
}

function oddict_put( o, kp, k, v ) {
    return o[ kp, k ] = v
}

function oddict_get( o, kp, k,      e ) {
    if ((e = o[ kp, k ]) != "") return e

    oddict_get_defined_by_user( o, kp )
}

function oddict_isleaf(){

}

