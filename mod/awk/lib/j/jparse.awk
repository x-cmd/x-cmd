function jparse(text, arr){
    ___jparse(json_to_machine_friendly(text), arr)
}

function jparse_(text){
    jparse(text, _)
}

function jparse0(text, arr){
    ___jparse(text, arr)
}

function jparse0_(text){
    jparse0(text, _)
}

# Section: details
function ___jparse_walk_panic(msg,       start){
    start = s_idx - 10
    if (start <= 0) start = 1
    print (msg " [index=" s_idx "]:\n-------------------\n" ___JSON_TMP_TOKENS[s_idx -2] "\n" ___JSON_TMP_TOKENS[s_idx -1] "\n" s "\n" ___JSON_TMP_TOKENS[s_idx + 1] "\n-------------------") > "/dev/stderr"
    exit 1
}

function ___jparse_walk_dict(arr, keypath,
    nth, cur_keypath, _result, _klist){
    if (s != "{") return false
    arr[ keypath ] = T_DICT

    nth = 0
    s = ___JSON_TMP_TOKENS[++s_idx]
    _klist=""

    while (1) {
        nth ++
        if (s == "}") {
            s = ___JSON_TMP_TOKENS[++s_idx];  break
        }

        cur_keypath = keypath S s
        _klist = _klist S s

        s = ___JSON_TMP_TOKENS[++s_idx]
        if (s != ":")   ___jparse_walk_panic("___jparse_walk_dict() Expect :")

        s = ___JSON_TMP_TOKENS[++s_idx]
        _result = ___jparse_walk_value(arr, cur_keypath)
        arr[ cur_keypath ] = _result

        if (s == ",") s = ___JSON_TMP_TOKENS[++s_idx]
    }
    arr[ keypath T_LEN ] = nth - 1  # starts from 1
    arr[ keypath T_KEY ] = _klist
    # TODO: arr[ keypath T_KEY ] = _klist (nth-1)
    return true
}

function ___jparse_walk_list(arr, keypath,
    nth, cur_keypath, _result){

    if (s != "[")   return false
    arr[ keypath ] = T_LIST

    nth = 0
    s = ___JSON_TMP_TOKENS[++s_idx]

    while (1) {
        nth++;
        if (s == "]") {
            s = ___JSON_TMP_TOKENS[++s_idx];   break
        }

        cur_keypath = keypath S "\"" nth "\""

        # if (s == ",")  ___jparse_walk_panic("___jparse_walk_list() Expect a value but get " s)
        _result = ___jparse_walk_value(arr, cur_keypath)
        arr[ cur_keypath ] = _result

        # TODO: just skip that token without judgement
        if (s == ",")   s = ___JSON_TMP_TOKENS[ ++s_idx ]
    }

    arr[ keypath T_LEN ] = nth - 1  # starts from 1
    return true
}

function ___jparse_walk_value(arr, keypath,  _result){
    if (___jparse_walk_dict(arr, keypath) == true) {
        return T_DICT
    }

    if (___jparse_walk_list(arr, keypath) == true) {
        return T_LIST
    }

    _result = s
    s = ___JSON_TMP_TOKENS[++s_idx]
    return _result
}

function ___jparse_walk(arr,    final, idx, nth){
    if (s == "")  s = ___JSON_TMP_TOKENS[++s_idx]

    nth = 0
    while (s_idx <= s_len) {
        if (___jparse_walk_value(arr, S "\"" ++nth "\"", "") == false) {
           ___jparse_walk_panic("json_walk() Expect a value")
        }
    }
    arr[ T_LEN ] = nth
}

# global variable: text, s, s_idx, s_len,
# ___JSON_TMP_TOKENS
function ___jparse(text, arr,       b_s, b_s_idx, b_s_len){
    b_s = s;    b_s_idx = s_idx;    b_s_len = s_len;

    s_len = split(text, ___JSON_TMP_TOKENS, /\n/)
    s = ___JSON_TMP_TOKENS[s_idx];     s_idx = 1;

    ___jparse_walk(arr)

    s = b_s;    s_idx = b_s_idx;    s_len = b_s_len;
}
# EndSection
