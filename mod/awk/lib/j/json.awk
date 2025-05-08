# Using it to power jawk

# { "a": "b", "a1": [1, 2, 3], "a2": { "age": 12 } }
# arr[ "a" SUBSEP 1]
# arr[ "a2" SUBSEP "age" ]
# arr[ "a" L ]
# arr[ "a" T ]

BEGIN {
    T_DICT = "{" # "\003"
    T_LIST = "[" # "\004"
    T_PRI = "\005"
    T_ROOT = "\006"

    T_KEY = "\007"
    T_LEN = L
}

# Section: handler: jkey, _jpath,
# function q(str){
#     gsub(/\\/, "\\\\", str)
#     gsub(/"/, "\\\"", str)
#     return "\"" str "\""
# }

# function uq(str){
#     gsub(/\\"/, "\"", str)
#     return substr(str, 2, length(str)-2)
# }

function jkey(a1, a2, a3, a4, a5, a6, a7, a8, a9,
    a10, a11, a12, a13, a14, a15, a16, a17, a18, a19,
    _ret){
    _ret = ""
    if (a1 == "")   return _ret;  _ret = ret SUBSEP jqu(a1)
    if (a2 == "")   return _ret;  _ret = _ret SUBSEP jqu(a2)
    if (a3 == "")   return _ret;  _ret = _ret SUBSEP jqu(a3)
    if (a4 == "")   return _ret;  _ret = _ret SUBSEP jqu(a4)
    if (a5 == "")   return _ret;  _ret = _ret SUBSEP jqu(a5)
    if (a6 == "")   return _ret;  _ret = _ret SUBSEP jqu(a6)
    if (a7 == "")   return _ret;  _ret = _ret SUBSEP jqu(a7)
    if (a8 == "")   return _ret;  _ret = _ret SUBSEP jqu(a8)


    if (a9 == "")   return _ret;  _ret = _ret SUBSEP jqu(a9)
    if (a10 == "")  return _ret;  _ret = _ret SUBSEP jqu(a10)
    if (a11 == "")  return _ret;  _ret = _ret SUBSEP jqu(a11)
    if (a12 == "")  return _ret;  _ret = _ret SUBSEP jqu(a12)
    if (a13 == "")  return _ret;  _ret = _ret SUBSEP jqu(a13)
    if (a14 == "")  return _ret;  _ret = _ret SUBSEP jqu(a14)
    if (a15 == "")  return _ret;  _ret = _ret SUBSEP jqu(a15)
    if (a16 == "")  return _ret;  _ret = _ret SUBSEP jqu(a16)
    if (a17 == "")  return _ret;  _ret = _ret SUBSEP jqu(a17)
    if (a18 == "")  return _ret;  _ret = _ret SUBSEP jqu(a18)
    if (a19 == "")  return _ret;  _ret = _ret SUBSEP jqu(a19)

    return ret
}

function jpathr(_jpath,     _ret ){
    _ret = jpath(_jpath)

    # \034 = S
    gsub(/\*/, "[^\034]+", _ret)
    # gsub(/\*/, "[^\001]+", _ret)
    return _ret
}

function jpath(_jpath,   _arr, _arrl, _i, _ret){
    if (_jpath ~ SUBSEP) return _jpath
    if (_jpath ~ /^\./) {
        _jpath = "1" _jpath
    }
    _arrl = split(_jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        _ret = _ret SUBSEP jqu(_arr[_i])
    }
    return _ret
}

function jpatharr(arr, a1, a2, a3, a4, a5, a6, a7, a8, a9,
    a10, a11, a12, a13, a14, a15, a16, a17, a18, a19 ){

    if (a1 == "")   return 0;   arr[1] = jqu(a1)
    if (a2 == "")   return 1;   arr[2] = jqu(a2)
    if (a3 == "")   return 2;   arr[3] = jqu(a3)
    if (a4 == "")   return 3;   arr[4] = jqu(a4)
    if (a5 == "")   return 4;   arr[5] = jqu(a5)
    if (a6 == "")   return 5;   arr[6] = jqu(a6)
    if (a7 == "")   return 6;   arr[7] = jqu(a7)
    if (a8 == "")   return 7;   arr[8] = jqu(a8)

    if (a9 == "")   return 8;   arr[9] = jqu(a9)
    if (a10 == "")  return 9;   arr[10] = jqu(a10)
    if (a11 == "")  return 10;  arr[11] = jqu(a11)
    if (a12 == "")  return 11;  arr[12] = jqu(a12)
    if (a13 == "")  return 12;  arr[13] = jqu(a13)
    if (a14 == "")  return 13;  arr[14] = jqu(a14)
    if (a15 == "")  return 14;  arr[15] = jqu(a15)
    if (a16 == "")  return 15;  arr[16] = jqu(a16)
    if (a17 == "")  return 16;  arr[17] = jqu(a17)
    if (a18 == "")  return 17;  arr[18] = jqu(a18)
    if (a19 == "")  return 18;  arr[19] = jqu(a19)

    return 19
}

function jget(obj, _jpath){
    _jpath = jpath(_jpath)
    if (obj[ _jpath ] == "[" || obj[ _jpath ] == "{"){
        return ___json_stringify_format_value(obj, _jpath, 4)
    }
    return obj[ _jpath ]
}

# function jlen(arr, _jpath){
#     return arr[ jpath(_jpath) L ]
# }

# function jtype(arr, _jpath){
#     return arr[ jpath(_jpath)]
# }

function jtokenize(text) {
    return json_to_machine_friendly(text)
}

function jtokenize_trim(text) {
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("[:,]" "\n", "", text)
    gsub("\n" "[:,]", "", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    return text
}

# function json_str_unquote2(str){
#     if (str !~ /^"/) { # "
#         return str
#     }
#     gsub(/\\\\/, "\001\001", str)
#     gsub(/\\"/, /"/, str)
#     gsub("\001\001", "\\\\", str)
#     return substr(str, 2, length(str)-2)
# }

# function json_str_quote2(str){
#     gsub(/\\/, "\\\\", str)
#     gsub(/"/, "\\\"", str)
#     return "\"" str "\""
# }

# EndSection

# Section: jrange jkey json_jpaths2arr
function ___json_range_trick(arr, max){
    if (arr[3] == "") {
        if (arr[1] > arr[2] && arr[1] > 0 && arr[2] > 0) {
            arr[3] = -1
        } else {
            arr[3] = 1
        }
    }
    if (arr[1] == "") {
        if (arr[3] > 0) arr[1] = 1
        else arr[1] = max
    }
    if (arr[1] < 0) {
        arr[1] = (arr[1] + max) % max + 1
    }
    if (arr[2] == "") {
        if (arr[3] > 0) arr[2] = max
        else arr[2] = 1
    }
    if (arr[2] < 0) {
        if (arr[3] > 0) arr[2] = max + arr[2]
        else arr[2] = max + arr[2] + 2
    }
}

function jrange(range, arrlen){
    if (range == "") {
        jrange_start = 1
        jrange_end = arrlen
        jrange_step = 1
    } else {
        _rangel = split(range, _range, ":")
        ___json_range_trick(_range, arrlen)

        jrange_step = int(_range[3])
        jrange_end = int(_range[2])
        jrange_start = int(_range[1])
    }
}

# # For jjoin, different from logic
function ___json_jpath_quote2(_jpath,   _arr, _arrl, _i, _ret){
    _arrl = split(_jpath, _arr, ".")
    _ret = ""
    for (_i = 1; _i<=_arrl; _i++) {
        if (_arr[_i] == "") continue
        if ( _i == 1 )  _ret = jqu(_arr[_i])
        else _ret = _ret SUBSEP jqu(_arr[_i])
    }
    return _ret
}

function json_jpaths2arr(arr,
    jpaths,
    _i, _arrl  ){

    _arrl = split(jpaths, arr, SUBSEP)
    for (_i=1; _i<=_arrl; ++_i) {
        arr[ _i ] = ___json_jpath_quote2( arr[ _i ] )
    }
    return _arrl
}

function json_namedjpaths2arr(arr,
    jpaths,
    _i, _arrl, _e, _e1, _e2, _idx, _title  ){

    _arrl = split(keystr, arr, SUBSEP)

    _title = ""

    for (_i=1; _i<=_arrl; ++_i) {
        _e = arr[ _i ]
        if ( _e ~ /=/) {
            _idx = index(_e, "=")
            _e1 = substr(_e, 1, _idx-1)
            _e2 = substr(_e, _idx+1)

            arr[ _i ] = ___json_jpath_quote2( _e2 )

        } else {
            _e1 = _e
            arr[ _i ] = ___json_jpath_quote2( _e )
        }

        if (_i == 1) _title = _e1
        else _title = _title sep2 _e1
    }

    arr[ L ] = _arrl

    return _title
}
# EndSection

# Section: jlist
function jlist_put(obj, keypath, value,          l){
    obj[ keypath L ] = l = obj[ keypath L ] + 1
    obj[ keypath SUBSEP "\"" l "\""] = value
}

function jlist_has(obj, keypath, value,          l, i) {
    l = obj[ keypath L ]
    for (i=1; i<=l; ++i) {
        if ( obj[keypath SUBSEP "\""i "\"" ] == value ) return true
    }
    return false
}

function jlist_rm_idx(obj, keypath, i,              l){
    if( i > ( l = obj[ keypath L ] ) ) return false
    for (obj[ keypath L ]=--l; i<=l; ++i) {
        jclear(obj, keypath SUBSEP "\""i"\"")
        jcp_cover(obj, keypath SUBSEP "\""i"\"", obj, keypath SUBSEP "\"" i+1 "\"" )
    }
    return true
}

# Notice: No GC ...
function jlist_rm_value(obj, keypath, value,            l, i, v) {
    l = obj[ keypath L ]
    for (i=1; i<=l; ++i) {
        v = obj[ keypath SUBSEP "\""i "\"" ]
        if (value == v) {
           for (obj[ keypath L ]=--l; i<=l; ++i) {
                jclear(obj, keypath SUBSEP "\""i"\"")
                jcp_cover(obj, keypath SUBSEP "\""i"\"", obj, keypath SUBSEP "\"" i+1 "\"" )
           }
           return true
        }
    }
    return false
}

function jlist_rm(obj, keypath,                             l, i, _kp, arr) {
    l = split(keypath, arr, SUBSEP)
    for(i=2; i<=l-1; ++i ) _kp = _kp SUBSEP arr[i]
    return jlist_rm_idx(obj, _kp, juq(arr[ l ]))
}

# function jlist_len(obj, keypath){
#     return obj[ keypath L ]
# }

function jlist_id2arr(obj, keypath, range, arr,             i, l){
    jrange(range, obj[ keypath L ])

    l=0
    if (jrange_step > 0) {
        for (i=jrange_start; i<=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath SUBSEP jqu(i)
        }
    } else {
        for (i=jrange_start; i>=jrange_end; i=i+jrange_step) {
            l = l + 1
            arr[l] = keypath SUBSEP jqu(i)
        }
    }
    return l
}

function jlist_key_value2arr(obj, keypath, arr, val, kp,          l, i){
    l = obj[ keypath L ]
    for (i=1; i<=l; ++i) arr[ kp obj[ keypath, jqu(i) ] ] = val
    return l
}

function jlist_value2arr(obj, keypath, range, arr, kp,          _, i, l){
    l = jlist_id2arr(obj, keypath, range, _)
    for (i=1; i<=l; ++i)    arr[ kp i ] = obj[ _[i] ]
    return l
}

function jlist_str2arr(obj, keypath, range, arr, kp,       _, i, l){
    l = jlist_id2arr(obj, keypath, range, _)
    for (i=1; i<=l; ++i)    arr[ kp i ] = jstr( obj, _[i] )
    return l
}

function jlist_str02arr(obj, keypath, range, arr, sep, kp,      _, i, l){
    l = jlist_id2arr(obj, keypath, range, _)
    for (i=1; i<=l; ++i)    arr[ kp i ] = jstr0( obj, _[i], sep )
    return l
}

function jlist_str12arr(obj, keypath, range, arr, kp,       _, i, l){
    l = jlist_id2arr(obj, keypath, range, _)
    for (i=1; i<=l; ++i)    arr[ kp i ] = jstr1( obj, _[i] )
    return l
}

# TOTEST
function jlist_join(sep, obj, keypath, range,      _ret_arr, i, l, _ret){
    l = jlist_value2arr(obj, keypath, range, _ret_arr)

    ret = ""
    for (i=1; i<=l; ++i) {
        if (ret != "")  ret = ret sep _ret_arr[i]
        else            ret = _ret_arr[i]
    }
    return ret
}

# TODO
# function jlist_totable(){
#     return true
# }

function jlist_grep_to_arr( obj, keypath, reg,  arr,        _arrl,    k, l, _ret, i, _tmp ){
    l = obj[ keypath L ]
    for(i=1; i<=l; ++i){
        _tmp = keypath SUBSEP "\"" i "\""
        if( match(juq( obj[ _tmp ] ), reg)){
            arr[ ++_arrl ] = _tmp
        }
    }
    return _arrl
}

# EndSection

# Section: jdict

# NOTICE: argument key is already quoted
function jdict_rm(obj, keypath, key,                    k, i, l){
    l = obj[ keypath L ]
    for (i=1; i<=l; ++i) {
        k = obj[ keypath, i ]
        if ( key == k ) {
            delete obj[ keypath, k ] # obj[ keypath, k ] = ""
            for (obj[ keypath L ]=--l; i<=l; ++i) obj[ keypath, i ] = obj[ keypath, i+1 ]
            return true
        }
    }
    return false
}

# TODO: We should quote
function jdict_put(obj, keypath, key, value,            v, l){
    v = obj[ keypath, key ]
    obj[ keypath, key ] = value
    if ( v == "" ) {
        obj[ keypath L ] = l = obj[ keypath L ] + 1
        obj[ keypath, l ] = key
    }
    return v
}

function jdict_has(obj, keypath, key,           v) {
    v = obj[ keypath, key ]
    return (v == "") ? false : true
}

# function jdict_get(obj, keypath, key){
#     return obj[ keypath, key ]
# }

# function jdict_len(obj, keypath){
#     return obj[ keypath L ]
# }

# TODO: to check
function jdict_value2arr(obj, keypath, arr,         i, l){
    arr[ L ] = l = obj[ keypath L ]
    for (i=1; i<=l; ++i) arr[i] = obj[ keypath, obj[ keypath, i ] ]
    return l
}

function jdict_keys2arr(obj, keypath, arr,          i, l){
    l = arr[ L ] = obj[ keypath L ]
    for (i=1; i<=l; ++i) arr[i] = obj[ keypath, i ]
    return l
}

function jdict_grep_to_arr( obj, keypath, reg,  arr,            _arrl,  _key, l, i ){
    l = obj[ keypath L ]
    for(i=1; i<=l; ++i){
        _key =obj[ keypath, i ]
        if( match( obj[ keypath SUBSEP _key ], reg)){
            arr[ ++_arrl ] = _key
        }
    }
    return _arrl
}

# EndSection

# Section: json convert to machine friendly
function json_to_machine_friendly(text){
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|:|,|\]|\[|\{|\}|null|false|true|[ \t\n\r]+/, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    gsub("^[\n]+", "", text)
    return text
}
# EndSection

function draw_space(num,     _i, _ret){ return sprintf("%" num "s", "");    }

function jstr(arr, keypath, indent){    return json_stringify_format(arr, keypath, indent);                     }
function jstr1(arr, keypath){           return json_stringify_machine(arr, keypath);                            }
function jstr0(arr, keypath, sep){      return json_stringify_machine(arr, keypath, ("" == sep) ? "\n": sep );  }

# Section: Machine Stringify
function ___json_stringify_machine_dict(obj, keypath, sep,      l, i, _key, _ret){
    l = obj[ keypath L ]
    if (l == 0) return "{" sep "}" sep

    _key = obj[ keypath, 1 ]
    _ret = _key sep ":" sep  ___json_stringify_machine_value( obj, keypath SUBSEP _key, sep )
    for (i=2; i<=l; i++){
        _key = obj[ keypath, i ]
        _ret = _ret "," sep _key sep ":" sep  ___json_stringify_machine_value( obj, keypath SUBSEP _key, sep )
    }
    return "{" sep  _ret "}" sep
}

function ___json_stringify_machine_list(obj, keypath, sep,    l, i, _ret){
    l = obj[ keypath L ]
    if (l == 0) return "[" sep "]" sep

    _ret = ___json_stringify_machine_value( obj, keypath SUBSEP "\"" 1 "\"", sep )
    for (i=2; i<=l; i++){
        _ret = _ret "," sep ___json_stringify_machine_value( obj, keypath SUBSEP "\"" i "\"", sep )
    }
    return "[" sep  _ret "]" sep
}

function ___json_stringify_machine_value(obj, keypath, sep,    _t, i, _ret){
    _t = obj[ keypath ]
    if (_t == "{")      return ___json_stringify_machine_dict(obj, keypath, sep)
    else if (_t == "[") return ___json_stringify_machine_list(obj, keypath, sep)
    else                return _t sep
}

function json_stringify_machine(obj, keypath, sep,   i, l,_ret){
    if (keypath != "") {
        keypath=jpath(keypath)
        return ___json_stringify_machine_value(obj, keypath, sep)
    }
    l = obj[ L ]
    if (l < 1)  return ""

    for (i=1; i<=l; ++i) {
        _ret = _ret ___json_stringify_machine_value( obj,  SUBSEP "\"" i "\"", sep)
    }

    return _ret
}
# EndSection

# Section: Format Stringify
function ___json_stringify_format_dict(obj, keypath, indent,        l, i, _key, _ret){
    l = obj[ keypath L ]
    if (l == 0) return "{ }\n"

    _key = obj[ keypath, 1 ]
    _ret = draw_space(indent) _key ": " ___json_stringify_format_value( obj, keypath SUBSEP _key, indent+INDENT_LEN )
    for (i=2; i<=l; i++){
        _key = obj[ keypath, i ]
        _ret = _ret ",\n" draw_space(indent) _key ": " ___json_stringify_format_value( obj, keypath SUBSEP _key, indent+INDENT_LEN )
    }
    return "{\n" _ret "\n" draw_space(indent-INDENT_LEN) "}"
}

function ___json_stringify_format_list(obj, keypath, indent,    l, i, _ret){
    l = obj[ keypath L ]
    if (l == 0) return "[ ]\n"

    _key = obj[ keypath, 1]
    _ret = draw_space(indent) ___json_stringify_format_value( obj, keypath SUBSEP "\"" 1 "\"", indent+INDENT_LEN)
    for (i=2; i<=l; i++){
        _ret = _ret ",\n" draw_space(indent) ___json_stringify_format_value( obj, keypath SUBSEP "\"" i "\"", indent+INDENT_LEN)
    }
    return "[\n" _ret "\n" draw_space(indent-INDENT_LEN) "]"
}

function ___json_stringify_format_value(obj, keypath, indent,   _t, i, _ret){

    _t = obj[ keypath ]
    if (_t == "{")      return ___json_stringify_format_dict(obj, keypath, indent)
    else if (_t == "[") return ___json_stringify_format_list(obj, keypath, indent)
    else                return _t
}

function json_stringify_format(obj, keypath, indent,       i, l,_ret){
    if (indent == "") indent=4
    INDENT_LEN = indent

    if (keypath != "") {
        keypath=jpath(keypath)
        return ___json_stringify_format_value(obj, keypath, indent)
    }

    l = obj[ L ]
    if (l < 1)  return ""

    _ret = ___json_stringify_format_value( obj, SUBSEP "\"" 1 "\"", indent )
    for (i=2; i<=l; ++i) {
        _ret = _ret "\n" ___json_stringify_format_value( obj, SUBSEP "\"" i "\"", indent )
    }

    return _ret
}
# EndSection

# TODO: This is a problem
function json_split2tokenarr( arr, text,    l ){
    l = split( json_to_machine_friendly(text), arr, "\n" )
    arr[ L ] = l
    return l
}

function json_split2tokenarr_( text,        _ ){
    return json_split2tokenarr( _, text )
}

# Section: still strange: should be global search

# TODO: ...
function jgrep_to_arr(obj, keypath, reg, key,      _t){
    _k = keypath
    keypath = jpath(keypath)

    _t = obj[ keypath ]
    if (_t == "{") {
        return jlist_grep_to_arr(obj, keypath, reg, key)
    }

    if (_t == "[") {
        return jdict_grep_to_arr(obj, keypath, reg, key)
    }

    return ""
}
# EndSection

# Section: jcp
function jcp_merge(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        jcp(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function jcp(o, kp1, obj, kp2){
    if ( o[ kp1 ] == "" ) {
        o[ kp1 ] = obj[ kp2 ]
        if ( o[ kp1] == "[" ) return jcp_list(o, kp1, obj, kp2)
    }
    if ( o[ kp1 ] == "{" ) return jcp_dict(o, kp1, obj, kp2)
}

function jcp_dict(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        jcp(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function jcp_list(o, kp1, obj, kp2,          l, i) {
    o[ kp1 L ] = l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) jcp(o, kp1 SUBSEP "\"" i "\"", obj, kp2 SUBSEP "\"" i "\"")
}

function jcp_cover_merge(o, obj,       l, i, kp){
    l = obj[L]
    for (i=1; i<=l; ++i){
        kp = SUBSEP jqu(i)
        jcp_cover(o, kp, obj, kp)
    }
    if (o[L] < l) o[L] = l
}

function jcp_cover(o, kp1, obj, kp2){
    o[ kp1 ] = obj[ kp2 ]
    if ( o[ kp1] == "[" )  return jcp_list_cover(o, kp1, obj, kp2)
    if ( o[ kp1 ] == "{" ) return jcp_dict_cover(o, kp1, obj, kp2)
}

function jcp_dict_cover(o, kp1, obj, kp2,          l, i, k, _l){
    l = obj[ kp2 L ]
    for (i=1; i<=l; ++i) {
        k = obj[ kp2, i ]
        if ( o[ kp1, k ] == "") {
            o[ kp1 L ] = ( _l = o[ kp1 L ] + 1 )
            o[ kp1, _l ] = k
        }
        jcp_cover(o, kp1 SUBSEP k, obj, kp2 SUBSEP k)
    }
}

function jcp_list_cover(o, kp1, obj, kp2,          l1, l2, i) {
    l1 = o[ kp1 L ]
    l2 = obj[ kp2 L ]
    for (i=1; i<=l2; ++i) jcp_cover(o, kp1 SUBSEP "\"" int(i+l1) "\"", obj, kp2 SUBSEP "\"" i "\"")
    o[ kp1 L ] = int(l1 + l2)
}
# EndSection

# Section: jclear
function jclear(o, kp,      v){
    v = o[ kp ]
    if (v == "{")   return jdict_clear( o, kp )
    if (v == "[")   return jlist_clear( o, kp )
    delete o[ kp ]
}

function jlist_clear( o, kp,     i, l ){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) delete o[ kp, "\""i"\"" ]
    o[ kp L ] = 0
}

function jdict_clear( o, kp,     i, l, k ){
    l = o[ kp L ]
    for (i=1; i<=l; ++i) {
        k = o[ kp, i ]
        delete o[ kp, i ]
        delete o[ kp, k ]
    }
    o[ kp L ] = 0
}

# EndSection

