
# Section: prepare argument
function prepare_argarr( argstr, arr,      l, i, _arg ){
    # if ( argstr == "" ) argstr = "" # "." "\002"

    gsub("\n", "\001", argstr)
    gsub("\\\\ ", " ", argstr)
    l = split(argstr, arr, "\002")
    arr[L] = l
    for (i=1; i<=l; ++i) {
        _arg = arr[i]
        gsub("\001", "\n", _arg)
        arr[i] = _arg
    }
}

# EndSection

# Section: parse argument into env table

# Complete Rest Argument
# Complete Option Name Or RestArgument
# Complete Option Argument

function env_table_set_true( key, keypath, genv_table, lenv_table ){
    env_table_set( key, keypath, 1, genv_table, lenv_table )
}

function env_table_set( key, keypath, value, genv_table, lenv_table ){
    genv_table[ keypath ] = value
    lenv_table[ key ] = value
}

function parse_args_to_env___option( obj, obj_prefix, args, argl, optarg_id, arg_idx, genv_table, lenv_table,
    _optargc, k ){
    if (optarg_id == "") return false
    _optargc = aobj_get_optargc( obj, obj_prefix, optarg_id )
    if (_optargc == 0) {    # This is a flag
        env_table_set_true( optarg_id, obj_prefix SUBSEP optarg_id, genv_table, lenv_table )
        return arg_idx
    }
    for (k=1; k<=_optargc; ++k)  {
        if ( arg_idx >= argl ) {
            advise_complete_option_value( args[ arg_idx ], genv_table, lenv_table, obj, obj_prefix, optarg_id, k )
            return ++arg_idx # Not Running at all .. # TODO
        }
        env_table_set( optarg_id, obj_prefix SUBSEP optarg_id SUBSEP k, args[ arg_idx++ ], genv_table, lenv_table )
        if ( parse_trim_args( obj, obj_prefix, args, arg_idx ) ) argl = args[ L ]
    }
    return arg_idx
}

# check obj_prefix kp args argl
function parse_trim_args( obj, kp, args, id,          v, k, i, j, l, n, nl, _, num, argl, tf ){
    if ( (tf = args[ id, "fixed" ]) != "" ) return tf
    v = args[ id ]
    l = aobj_len(obj, kp)
    for (i=1; i<=l; ++i){
        k = aobj_get(obj, kp SUBSEP i)
        if ( ! aobj_is_nospace(obj, kp SUBSEP k) ) continue
        CAND[ kp, k, "IS_NOSPACE" ] = true
        nl = split(juq(k), _, "|")
        for (n=1; n<=nl; ++n){
            if (match(v, "^" _[n])) {
                CAND[ kp, k, "PREFIX" ] = _[n]
                CAND[ "NOSPACE_NUM" ] ++
                args[ id ] = substr(v, 1, RLENGTH)
                argl = args[ L ] = args[ L ] + 1
                num = id + 1
                for (j=argl; j>num; --j) args[ j ] = args[ j - 1 ]
                args[ num ] = substr(v, RLENGTH+1)
                return ( args[ id, "fixed" ] = true )
            }
        }
    }
    return ( args[ id, "fixed" ] = false )
}

function parse_args_to_env( args, obj, obj_prefix,              genv_table, lenv_table, i, j, k, _arg_id, _subcmdid, _optarg_id, _arg_arrl, _optargc, _rest_argc, rest_argc_max, argl, arg ){

    # TODO: subcmd nospace
    if (! advise_get_ref_and_group(obj, obj_prefix)) return false
    parse_trim_args(obj, obj_prefix, args, (i = 1))
    argl = args[ L ]
    CAND[ "KEYPATH" ] = obj_prefix
    while ( i<argl ) {
        arg = args[ i ];    i++
        _arg_id = aobj_get_id_by_name( obj, obj_prefix, arg )
        _subcmdid = aobj_get_subcmdid_by_id( obj, obj_prefix, _arg_id )
        if (_subcmdid != "") {
            if ( ! aobj_option_all_set( lenv_table, obj, obj_prefix ) ) {
                return advise_error("All required options should be set")
            }
            obj_prefix = obj_prefix SUBSEP _subcmdid
            CAND[ "KEYPATH" ] = obj_prefix
            if (! advise_get_ref_and_group(obj, obj_prefix)) return false
            if ( parse_trim_args(obj, obj_prefix, args, i) ) argl = args[ L ]
            delete lenv_table
            continue
        }

        if (aobj_is_option( obj, obj_prefix SUBSEP _arg_id ) || (arg ~ /^--/)) {
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, _arg_id, i, genv_table, lenv_table )
            argl = args[ L ]
            if (j > argl) return true       # Not Running at all
            else if (j != 0) { i = j; continue; }
            else { i = i - 1; break; }
        } else if (arg ~ /^-/) {
            j = parse_args_to_env___option( obj, obj_prefix, args, argl, _arg_id, i, genv_table, lenv_table )
            argl = args[ L ]
            if (j > argl) return true       # Not Running at all
            else if (j != 0) { i = j; continue; }

            _arg_arrl = split(arg, _arg_arr, "")
            for (j=2; j<=_arg_arrl; ++j) {
                _optarg_id = aobj_get_id_by_name( obj, obj_prefix, "-" _arg_arr[j] )
                if ( _optarg_id == "" ) break
                _optargc = aobj_get_optargc( obj, obj_prefix, _optarg_id )
                if (_optargc == 0) {
                    env_table_set_true( _optarg_id, obj_prefix SUBSEP _optarg_id, genv_table, lenv_table )
                    continue
                }

                if (j<_arg_arrl) return advise_error("Fail at parsing: " arg ". Accept at least one argument: -" _arg_arr[j] )

                for (k=1; k<=_optargc; ++k)  {
                    if ( i>=argl ) {
                        advise_complete_option_value( args[i], genv_table, lenv_table, obj, obj_prefix, _optarg_id, k )
                        return true # Not Running at all .. # TODO
                    }
                    env_table_set( _optarg_id, obj_prefix SUBSEP _optarg_id SUBSEP k, args[ i++ ], genv_table, lenv_table )
                }
            }
            continue
        }
        i = i - 1 # subcmd complete
        break
    }
    # handle it into argument

    CAND[ "OFFSET" ] = i - CAND[ "NOSPACE_NUM" ]
    CAND[ "NOSPACE_NUM" ] = 0

    for (j=1; i+j-1 < argl; ++j) rest_arg[ j ] = args[ i+j-1 ]
    _rest_argc = j - 1

    arg = args[ argl ]
    if (_rest_argc == 0) return advise_complete_option_name_or_argument_value( arg, genv_table, lenv_table, obj, obj_prefix )

    rest_argc_max = aobj_get_maximum_rest_argc( obj, obj_prefix )
    if (_rest_argc >= rest_argc_max)  return

    return advise_complete_argument_value( arg, genv_table, lenv_table, obj, obj_prefix, _rest_argc+1 )

}
# EndSection
