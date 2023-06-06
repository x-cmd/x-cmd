
# Section: Assert
function assert_arr_eq(optarg_id, arg_name, value, sep,
    op_arr_len, i, idx, value_arr_len, value_arr, candidate, sw){

    op_arr_len = option_arr[ oparr_keyprefix L ]

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=op_arr_len; ++idx) {
            candidate = oparr_get( optarg_id, idx )
            candidate = str_unquote_if_quoted( candidate )
            if ( value_arr[i] == candidate ) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg( option_id, value_arr[i], oparr_join_plain( optarg_id ))
        }
    }
}

function assert_arr_regex(optarg_id, arg_name, value, sep,
    i, value_arr_len, value_arr, sw){

    len = oparr_len( optarg_id )

    value_arr_len = split(value, value_arr, sep)
    for (i=1; i<=value_arr_len; ++i) {
        sw = false
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (match( value_arr[i], val )) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, value_arr[i], oparr_join_plain( optarg_id ) )
        }
    }
}

# op_arg_idx # token_arr_len, token_arr, op_arg_idx,
function assert(optarg_id, arg_name, arg_val,
    op, sw, idx, len, val, _tmp){

    op = oparr_get( optarg_id, 1 )
    # debug("assert: optarg_id: " optarg_id " arg_name: " arg_name " arg_val: " arg_val " op: " op " oparr_keyprefix: " oparr_keyprefix)

    if (op == "=int") {
        if (! match(arg_val, "^[+-]?[0-9]+$") ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            return "Arg: [" arg_name "] value is [" arg_val "]\nIs not an integer."
        }

        if ( 2 <= len = oparr_len( optarg_id )){
            for (idx=2; idx<=len; ++idx) {
                val = oparr_get( optarg_id, idx )
                val = str_unquote_if_quoted( val )
                if (val ~ "^[+-]?[0-9]+$") {
                    if (arg_val == val) return true
                } else {
                    if (seq_within( arg_val, val )) return true
                }
            }
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg(option_id, arg_val, oparr_join_plain(optarg_id) )
        }

    } else if ( op == "=email" ) {
        if (! match(arg_val, "^"RE_EMAIL"$") ) {
            return "Arg: [" arg_name "] value is [" arg_val "]\nIs not a Correct Email Address ."
        }
    } else if (match(op, "^=url(:.+)?")) {      # =url:http   =url:https    =url:ftp
        _tmp = substr(op, 6)
        if (_tmp == ""){
            if(! re_wmatch(arg_val, RE_URL_BODY) ) {
                return "Arg: [" arg_name "] value is [" arg_val "]\nIs not an Url."
            }
        } else if (! re_wmatch(arg_val, "(" _tmp "://)" RE_URL_BODY) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            return "Arg: [" arg_name "] value is [" arg_val "]\nIs not the specified Url."
        }
    } else if (op == "=") {
        sw = false
        len = oparr_len( optarg_id )
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (val ~ "^/.*/$") {
                if (match(arg_val, "^"substr(val, 2, length(val)-2)"$")) {
                    sw = true
                    break
                }
            } else {
                if (arg_val == val) {
                    sw = true
                    break
                }
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_candidate_error_msg(option_id, arg_val, oparr_join_plain(optarg_id) )
        }
    } else if (op == "=~") {
        sw = false
        len = oparr_len( optarg_id )
        for (idx=2; idx<=len; ++idx) {
            val = oparr_get( optarg_id, idx )
            val = str_unquote_if_quoted( val )
            if (match(arg_val, "^"val"$")) {
                sw = true
                break
            }
        }
        if (sw == false) {
            option_id = optarg_id
            gsub("\034[0-9]+$", "", option_id)
            return panic_match_regex_error_msg( option_id, arg_val, oparr_join_plain(optarg_id) )
        }

    } else if (op ~ /^=.$/) {
        sep = substr(op, 2, 1)
        assert_arr_eq( optarg_id, arg_name, arg_val, sep )
    } else if (op ~ /^=~.$/) {
        sep = substr(op, 3, 1)
        assert_arr_regex( optarg_id, arg_name, arg_val, sep )
    } else if (op == "") {
        # Do nothing.
    } else {
        # debug( "Op[" op "] Not Match any candidates: \n" line )
        panic_param_define_error("Straing op: " op)
    }

    return true
}
## EndSection
