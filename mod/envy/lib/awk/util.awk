function envy_load(o, var, compile_kp){
    if (compile_kp == "") return envy_load_list(o, "", var)

    compile_kp = jpath(compile_kp)
    var[ "compile" ] = compile_kp
    return envy_load_value(o, compile_kp, var)
}

function envy_load_value(o, kp, var,     v, i){
    v = o[ kp ]
    if (v == "{") return envy_load_dict(o, kp, var)
    if (v == "[") return envy_load_list(o, kp, var)
    if (v == "")  return
    envy_load_push(var, kp, v)
}

function envy_load_dict(o, kp, var,      l, i){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) envy_load_value(o, kp SUBSEP o[ kp, i ], var)
}

function envy_load_list(o, kp, var,      l, i){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) envy_load_value(o, kp SUBSEP "\""i"\"", var)
    envy_load_value(o, kp L, var)
}

function envy_load_push(var, kp, v,          name, compile_kp, i){
    compile_kp = var[ "compile" ]
    name = envy_kp_to_name( substr( kp, length(compile_kp) + 1 ) )
    i = arr_push(var, name)
    var[ i, "value" ] = v
    var[ i, "kp" ] = kp
}

function envy_gen_code( var, perfix, local, override, backup,           i, l, v, name, _res_backup, _res_local, _res ){
    l = var[ L ]
    for (i=1; i<=l; ++i){
        name = perfix var[i]
        v = var[ i, "value" ]
        v = (v ~ "^\"") ? juq(v) : v
        if (backup == "enable") {
            _res_backup = _res_backup "  ___x_cmd_shq1_ \"$" name "\"\n"
            if (ENVIRON[ name ]) {
                _res_backup = _res_backup sprintf("  printf %s %s\n", "\"  export %s\\n\"", name"=\"$x_\"")
            } else {
                _res_backup = _res_backup sprintf("  printf %s %s\n", "\"  ___x_cmd_unexport %s\\n\"", name)
                _res_backup = _res_backup sprintf("  printf %s %s\n", "\"  %s\\n\"", name"=\"$x_\"")
            }
        }
        if (local == "enable")  _res_local = _res_local "  local " name "\n"
        if (override != "enable") _res = _res name"=\"${"name"-"str_quote2(v)"}\"\n"
        else _res = _res var_set( name, v ) "\n"
    }

    if (_res_backup != "") _res_backup = perfix "_BACKUP=\"$(\n" _res_backup ")\"\n"
    if (_res_local != "") _res_local = "{\n" _res_local "} 2>/dev/null\n"
    return _res_backup _res_local _res
}


function envy_name_to_kp(name,      i, l, _, kp){
    l = split( name, _, "_")
    for (i=2; i<=l; ++i) kp = kp SUBSEP jqu(_[i])
    return kp
}

function envy_kp_to_name(kp,        i, l, name, _, _item, _last_item){
    l = split(kp, _, SUBSEP)
    _last_item = _[l]
    if (_last_item ~ L"$") {
        _[l] = substr(_last_item, 1, length(_last_item) - length(L))
        _[ ++l ] = "L"
    }

    for (i=2; i<=l; ++i) {
        _item = _[i]
        _item = (_item ~ "^\"") ? juq(_item) : _item
        name = name "_" _item
    }
    return name
}

function envy_parse_namelist(obj, namelist,         i, l, _, item, id, name, value, idx){
    l = split( namelist, _, "\n" )
    for (i=1; i<=l; ++i){
        if ( "" == (item = _[i]) ) continue
        id = index(item, "=")
        name = substr(item, 1, id-1)
        value = substr(item, id+1)
        idx = arr_push(obj, name)
        obj[ idx, "value" ] = value
        obj[ idx, "kp" ] = envy_name_to_kp(name)
    }
}

function envy_put(o, kp, val,            i, l, _val, _kp, arr, _item){
    l = split( kp, arr, SUBSEP )
    for (i=2; i<=l; ++i){
        _item = arr[i]
        if (i == l) _val = jqu(val)
        else if (arr[i+1] !~ "\"[0-9]+\"") _val = "{"
        else  _val = "["

        if ( o[ _kp ] == "{" ) {
            if ((i != l) || (!jdict_has(o, _kp, _item)))  jdict_put(o, _kp, _item, _val)
            else o[ _kp, _item ] = _val
        }
        else if ( o[ _kp ] == "[" ) {
            if (o[ _kp L ] >= int(juq(_item))) o[ _kp, _item ] = _val
            else jlist_put(o, _kp, _val)
        }
        _kp = _kp SUBSEP arr[i]
    }
}

