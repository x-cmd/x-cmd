
# Section: jref
function jref_get( obj, key,    r ){
    if (obj[ key ] != "{" )  return false
    if ( (r = obj[ key, "\"$ref\"" ]) == "" ) return false
    return r
}

function jref_set( obj, key, ref ){
    obj[ key ] = "{"
    obj[ key L ] = 1
    obj[ key 1 ] = "\"$ref\""
    obj[ key, "\"$ref\"" ] = ref
}

function jref_clear(obj, key){
    obj[ key, "\"$ref\"" ] = ""
}

function jref_replace_with_empty_dict( obj, key, ref ){
    obj[ key ] = "{"
    obj[ key L ] = 0
}

function jref_replace_with_empty_list( obj, key, ref ){
    obj[ key ] = "["
    obj[ key L ] = 0
}
# EndSection
