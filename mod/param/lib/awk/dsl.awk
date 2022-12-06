# Section: token argument
BEGIN{
    PARAM_RE_1 = "<[A-Za-z0-9_ ]*>" "(:[A-Za-z_\\-]+)*"
    PARAM_RE_1_2 = "=" re( RE_STR2 )
    PARAM_RE_1 = PARAM_RE_1 re( PARAM_RE_1_2, "?" )
    PARAM_RE_ARG = re( PARAM_RE_1 ) RE_OR re( RE_STR2 ) RE_OR re( RE_STR0 )# re( "[^ \\t\\v\\n]+" "((\\\\[ ])[^ \\t\\v\\n]*)*" )# re(RE_STR0) # re( "[A-Za-z0-9\\-_=\\#|]+" )

    PARAM_RE_NEWLINE_TRIM_SPACE = "[ \t\v]+"
    PARAM_RE_NEWLINE_TRIM = re("\n" PARAM_RE_NEWLINE_TRIM_SPACE) RE_OR re(PARAM_RE_NEWLINE_TRIM_SPACE "\n" )
}

function param_tokenized( s, arr,       l ){
    gsub( PARAM_RE_ARG, "\n&", s )
    gsub( PARAM_RE_NEWLINE_TRIM, "\n", s )
    gsub( "^[\n]+" RE_OR "[\n]+$", "", s)
    gsub( "\"", "", s)
    l = split(s, arr, "\n")
    return l
}

function tokenize_argument( astr, array,  l ) {
    l = param_tokenized( astr, array )
    array[ L ] = l
    return l
}
# EndSection

# Section: Step 2 Utils: Parse param DSL
BEGIN {
    final_rest_argv[ L ]    = 0
}

function handle_option_id( _option_id,            _arr, _arr_len, _arg_name, i ){
    # Add _option_id to option_id_list
    option_multarg_disable( _option_id )

    _arr_len = split( _option_id, _arr, /\|/ )
    for ( i=1; i<=_arr_len; ++i ) {
        _arg_name = _arr[ i ]
        if (_arg_name == "m") {
            option_multarg_enable( _option_id )
            continue
        }

        if (option_exist_by_alias( _arg_name ))    panic_param_define_error("Already exsits: " _arg_name)       # Prevent name conflicts
        option_set_alias( _option_id, _arg_name )

        if ( i == 1 )  option_name_set( _option_id, _arg_name )
    }

}

function handle_optarg_declaration( arg_tokenarr, optarg_id,            _optarg_definition_token1, _optarg_type,    _type_rule, i ){
    _optarg_definition_token1 = arg_tokenarr[ 1 ]

    if (! match( _optarg_definition_token1, /^<[-_A-Za-z0-9]*>/) ) {
        panic_param_define_error("Unexpected optarg declaration: \n" _optarg_definition_token1)
    }

    optarg_name_set( optarg_id,         substr( _optarg_definition_token1, 2,           RLENGTH-2 )  )

    _optarg_definition_token1       =   substr( _optarg_definition_token1, RLENGTH+1 )

    if (match( _optarg_definition_token1, /^:[-_A-Za-z0-9]+/) ) {
        _optarg_type                =   substr( _optarg_definition_token1, 2,           RLENGTH-1 )
        _optarg_definition_token1   =   substr( _optarg_definition_token1, RLENGTH+1 )
    }

    if ( _optarg_definition_token1 ~ /^=/ ) {
        optarg_default_set( optarg_id,  str_unquote_if_quoted( substr( _optarg_definition_token1, 2 ) )  )
    } else {
        optarg_default_set_required( optarg_id )
    }

    if (arg_tokenarr[ L ] < 2) {
        _type_rule = type_rule_by_name( _optarg_type )
        if (_type_rule == "")  return
        tokenize_argument( _type_rule, arg_tokenarr )
    }

    for ( i=2; i<=arg_tokenarr[ L ]; ++i ) oparr_add( optarg_id, arg_tokenarr[i] )  # quote
}

# options like #1, #2, #3 ...
function parse_param_dsl_for_positional_argument( line,          _option_id, _arr_len, _arr, i, _arg_name, _arg_no, _optarg_id, _arg_tokenarr ){

    tokenize_argument( line, _arg_tokenarr )

    _option_id = _arg_tokenarr[1]

    restopt_add_id( _option_id )

    option_argc_set( _option_id, 1 )
    option_multarg_disable( _option_id )

    _arr_len = split( _option_id, _arr, /\|/ )
    for ( i=1; i <= _arr_len; ++i ) {
        _arg_name = _arr[ i ]
        # Prevent name conflicts
        if (option_exist_by_alias( _arg_name ))     panic_param_define_error("Already exsits: " _arg_name)
        option_set_alias( _option_id, _arg_name )

        if ( i == 1 )              _arg_no = substr( _arg_name, 2)
        else if ( i == 2 )         option_name_set( _option_id, _arg_name )
    }

    option_desc_set( _option_id, _arg_tokenarr[2] )
    if ( _arg_tokenarr[ L ] >= 3 ) {

        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, _option_id )

        # NOTICE: this is correct. Only if has default value, or it is required !
        if (final_rest_argv[ L ] < _arg_no)   final_rest_argv[ L ] = _arg_no
        final_rest_argv[ _arg_no ] = optarg_default_get( _option_id )
        # TODO: validate this argument
        # debug( "final_rest_argv[ " _arg_no " ] = " final_rest_argv[ _arg_no ] )
    }

}

# options #n
function parse_param_dsl_for_all_positional_argument( line,                  _option_id, _arg_tokenarr ){

    tokenize_argument( line, _arg_tokenarr )

    _option_id = _arg_tokenarr[1]  # Should be #n

    restopt_add_id( _option_id )
    option_desc_set( _option_id, _arg_tokenarr[2] )
    if ( _arg_tokenarr[ L ] >= 3) {
        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, _option_id )
    }
}

function parse_param_dsl_for_named_options( _line_arr, line, i,            _nextline, _option_id, _arg_tokenarr, j, _tmp_idx ){
    # HANDLE:   option like --user|-u, or --verbose
    arr_push( option_arr, line )

    tokenize_argument( line, _arg_tokenarr )
    _option_id = _arg_tokenarr[1]
    handle_option_id( _option_id )
    option_desc_set( _option_id, _arg_tokenarr[2] )

    j = 0
    if ( _arg_tokenarr[ L ] >= 3) {
        j = j + 1
        arr_shift( _arg_tokenarr, 2 )
        handle_optarg_declaration( _arg_tokenarr, _option_id SUBSEP j )
    }

    while (true) {
        i += 1
        # debug("_line_arr[ " i " ]" _line_arr[ i ])
        _nextline = str_trim( _line_arr[ i ] )
        if ( _nextline !~ /^</ ) {
            i--
            break
        }

        j = j + 1
        tokenize_argument( _nextline, _arg_tokenarr )
        handle_optarg_declaration( _arg_tokenarr, _option_id SUBSEP j )
    }

    option_argc_set( _option_id, j )
    if (j==0)       flag_add_id( _option_id )
    else            namedopt_add_id( _option_id )
    return i
}

BEGIN{
    STATE_ADVISE        = 1
    STATE_TYPE          = 2
    STATE_OPTION        = 3
    STATE_SUBCOMMAND    = 4
    STATE_ARGUMENT      = 5
}

function parse_param_dsl(line,                      _line_arr_len, _line_arr, i, _state, _tmp_arr, _subcmd_funcname) {
    _state = 0
    _line_arr_len = split(line, _line_arr, "\n")

    for (i=1; i<=_line_arr_len; ++i) {
        line = str_trim( _line_arr[i] )         # TODO: line should be line_trimed

        if (line == "") continue

        if (line ~ /^advise:/)                                      _state = STATE_ADVISE
        else if (line ~ /^type:/)                                   _state = STATE_TYPE
        else if (line ~ /^options?:/)                               _state = STATE_OPTION
        else if (line ~ /^((subcommand)|(subcmd))s?:/)          {   _state = STATE_SUBCOMMAND; split(line, _tmp_arr, ":"); _subcmd_funcname = str_trim( _tmp_arr[2] ); }
        else if (line ~ /^arguments?:/)                             _state = STATE_ARGUMENT
        else {
            if (_state == STATE_ADVISE)                              advise_add( line )
            else if ( _state == STATE_TYPE )                         type_add_line( line )
            else if ( _state == STATE_SUBCOMMAND )                   subcmd_add_line( line, _subcmd_funcname )
            else if ( _state == STATE_OPTION ) {
                if ( match(line, "^#n[ \t\r\n\v]*" ) )               parse_param_dsl_for_all_positional_argument( line )         # HANDLE:   option like #n
                else if ( match( line, "^#[0-9]+[ \t\r\n\v]*" ) )    parse_param_dsl_for_positional_argument( line )             # HANDLE:   option like #1 #2 #3 ...
                else                                            i =  parse_param_dsl_for_named_options( _line_arr, line, i )                # HANDLE:   option like --token|-t
            }
        }
    }
}

# EndSection

# Section: Step 3 Utils: Handle code
function check_required_option_ready(       i, j, _option_argc, _option_id, _option_m, _option_name, _ret, _varname, _value ) {
    for ( i=1; i <= namedopt_len(); ++i ) {
        _option_id       = namedopt_get( i )
        _option_m        = option_multarg_get( _option_id )
        _option_name     = option_name_get_without_hyphen( _option_id )

        if ( option_arr_assigned[ _option_id ] == true ) {      # if assigned, continue
            # count the number of arguments
            if ( _option_m == true )    code_append_assignment( _option_name "_n",      option_assign_count_get( _option_id ) )
            continue
        }

        if ( 0 == ( _option_argc = option_argc_get( _option_id ) ) )    continue        # This is a flag
        if ( true == _option_m )        _option_name = _option_name "_" 1

        for ( j=1; j<=_option_argc; ++j ) {
            if ( (j==1) && (_option_argc == 1) ) {           # if argc == 1
                _varname    = _option_name
                _value      = (_option_name in option_default_map) ? option_default_map[ _option_name ] : optarg_default_get( _option_id SUBSEP 1 )
            } else {                                        # if argc >= 2
                _varname    = _option_name "_" j
                _value      = optarg_default_get( _option_id SUBSEP j )
            }

            if ( optarg_default_value_eq_require( _value ) ) {
                if ( ! is_interactive() )       panic_required_value_error( _option_id )
                code_query_append_by_optionid_optargid( _varname, _option_id, _option_id SUBSEP j )
                continue
            }

            if (( _value !="" ) && ( true != ( _ret = assert( _option_id SUBSEP j, _varname, _value ) ) )) {
                if ( ! is_interactive() )       panic_error( _ret )
                else                            code_query_append_by_optionid_optargid( _varname, _option_id, _option_id SUBSEP j )
                continue
            }

            if ( true != _option_m ) {
                code_append_assignment( _varname, _value )
                continue
            }

            if ( _value == "" )     code_append_assignment( _option_name "_n", 0 )   # TODO: should be 0. Handle later.
            else                    code_append_assignment( _varname, _value )
        }
    }
}
# EndSection

# Section: 1-GetTypes   2-GetSubcmd     3-DSL
function parse_type( code,     i, l, _arr, e ){
    l = split(str_trim(code), _arr, ARG_SEP)
    for (i=1; i<=l; ++i) {
        e = str_trim( _arr[i] )
        if ( 0 != length( e ) )     type_add_line(e)
    }
}

function parse_plugin_subcmd( code,     i, l, _arr, e ){
    code = substr( str_trim( code ), 2 )
    l = split(code, _arr, ARG_SEP)
    for (i=1; i<=l; ++i) {
        e = str_trim( _arr[i] )
        if (0 != length( e ))  subcmd_add_line( e )
    }
}

NR==1 {     parse_type( $0 )  }
NR==2 {     parse_plugin_subcmd( $0 )  }
NR==3 {     parse_param_dsl($0)         }
NR==4 {
    str_split( $0, arg_arr, ARG_SEP )
    code_append_assignment( "PARAM_SUBCMD", "" )    # Prevent the passing of PARAM_SUBCMD from invokers
}
# EndSection
