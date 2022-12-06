

BEGIN{
    HELP_INDENT_STR = "    "
    DESC_INDENT_STR = "   "
}

# Section: utils

function str_cut_line( _line, indent,               _max_len, _len, l, i){
    if( COLUMNS == "" )     return _line

    _max_len = COLUMNS - indent
    if ( length(_line) < _max_len )  return _line

    l = split( _line, _arr, " " )
    if ( length(_arr[1]) < _max_len ){
        for(i=1; i<=l; ++i){
            _len += ( length(_arr[i]) + 1)
            if (_len >= _max_len) {
                _len -= ( length(_arr[i]) + 1 )
                break
            }
        }
    } else {
        _len = _max_len
    }
    return substr(_line, 1, _len) "\n" str_rep(" ", indent)  str_cut_line( substr(_line, _len + 1 ), indent )
}

# General default/candidate/regex rule string.
# Example: [default: fzf] [candidate: fzf, skim] [regex: ^(fzf|skim)$ ] ...
function generate_optarg_rule_string(optarg_id,     _op, _regex, _candidate) {
    _default = optarg_default_get( optarg_id )
    _op = oparr_get( optarg_id, 1 )
    gsub(OPTARG_DEFAULT_REQUIRED_VALUE, "", _default)

    # BUG: _default != "", _default could be "" or null
    if (_default != "" && ! optarg_default_value_eq_require( _default ) )    _default = " [default: " _default "]"

    if ( _op == "=~" )  return _default " [regex: "     oparr_join_wrap( optarg_id, "|" ) "]"
    if ( _op == "="  )  return _default " [candidate: " oparr_join_wrap( optarg_id, ", " ) "]"

    return _default
}
# EndSection

# Section: option_help

# For Help Doc Generation

# Get max length of _opt_help_doc, and generate opt_text_arr.
function generate_help_for_namedoot_cal_maxlen_desc( opt_text_arr,            l, i, _len, _max_len, _opt_help_doc ){
    _max_len = 0
    l = opt_text_arr[ L ]
    for ( i=1; i<=l; ++i ) {
        opt_text_arr[ i ]   =  _opt_help_doc    = get_option_string( opt_text_arr[ i ] )       # obj[ i ] is option_ids
        opt_text_arr[ i L ] = _len              = length( _opt_help_doc )        # TODO: Might using wcswidth
        if ( _len > _max_len )    _max_len = _len
    }
    return _max_len
}

function generate_help_for_flag(         l, i, opt_text_arr, _res, _option_after, _max_len, _option_id ){
    flag_clone( opt_text_arr )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( opt_text_arr )

    _res = "FLAGS:\n"
    l = flag_len()
    for ( i=1; i<=l; ++i )
        _res = _res HELP_INDENT_STR sprintf("%s" DESC_INDENT_STR "%s\n",
            FG_BLUE         str_pad_right(opt_text_arr[ i ], _max_len),
            FG_LIGHT_RED    str_cut_line( option_desc_get( flag_get( i ) ), _max_len+7 ) UI_END)
    return _res
}

function generate_help_for_option(         l, i, opt_text_arr, _res, _option_after, _max_len, _option_argc ){
    namedopt_clone( opt_text_arr )
    _max_len = generate_help_for_namedoot_cal_maxlen_desc( opt_text_arr )

    _res = "OPTIONS:\n"
    l = namedopt_len()
    for ( i=1; i<=l; ++i ) {
        option_id = namedopt_get( i )
        _option_after  = option_desc_get( option_id ) UI_END

        _option_argc   = option_argc_get( option_id )
        for( j=1; j<=_option_argc; ++j ) _option_after = _option_after generate_optarg_rule_string( option_id SUBSEP j )
        _option_after = _option_after ( option_multarg_is_enable( option_id ) ? " [multiple]" : "" )

        _res = _res HELP_INDENT_STR sprintf( "%s" DESC_INDENT_STR "%s\n",
            FG_BLUE         str_pad_right(opt_text_arr[ i ], _max_len),
            FG_LIGHT_RED    str_cut_line( _option_after, _max_len+7 ) )
    }
    return _res
}

# There are two types of options:
# 1. Options without arguments, is was flags.
# 2. Options with arguments.
#   For example, --flag1, --flag2, --flag3, ...
#   For example, --option1 value1, --option2 value2, --option3 value3, ...
function generate_option_help(         _res) {
    _res = ""
    if ( 0 != flag_len() )          _res = _res "\n" generate_help_for_flag()
    if ( 0 != namedopt_len() )      _res = _res "\n" generate_help_for_option()
    return _res
}

# EndSection

# Section: rest_argument_help
function generate_rest_argument_help(        _res, _option_after, l) {
    # Get max length of rest argument name.
    _max_len = 0
    for (i=1; i<=restopt_len(); ++i) {
        l = length( restopt_get( i ) )
        if (l > _max_len) _max_len =l
    }

    # Generate help doc.
    _res = "\nARGS:\n"
    for (i=1; i <= restopt_len(); ++i) {
        option_id       = restopt_get( i )

        _option_after = option_desc_get( option_id ) UI_END generate_optarg_rule_string( option_id )

        _res = _res HELP_INDENT_STR sprintf( "%s" DESC_INDENT_STR "%s\n",
            FG_BLUE         str_pad_right(option_id, _max_len),
            FG_LIGHT_RED    str_cut_line( _option_after, _max_len+7 ) )
    }
    return _res
}
# EndSection

# Section: subcommand_help
function generate_subcommand_help(        _res, _cmd_name) {
    # Get max length of subcommand name.
    _max_len = 0
    for (i=1; i<=subcmd_len(); ++i) {
        if (length(subcmd_id( i )) > _max_len) _max_len = length(subcmd_id( i ))
    }

    # Generate help doc.
    _res = "\nSUBCOMMANDS:\n"
    for (i=1; i <= subcmd_len(); ++i) {
        _cmd_name = subcmd_id( i )
        gsub("\\|", ",", _cmd_name)

        _res = _res HELP_INDENT_STR sprintf("%s"  DESC_INDENT_STR "%s\n",
            FG_BLUE         str_pad_right(_cmd_name, _max_len),
            FG_LIGHT_RED    subcmd_desc(i) UI_END )
    }

    return _res "\nRun 'CMD SUBCOMMAND --help' for more information on a command\n"
}
# EndSection

function print_helpdoc(){
    if (0 != namedopt_len() || 0 != flag_len() )                printf("%s", generate_option_help())
    if (0 != restopt_len())                                     printf("%s", generate_rest_argument_help())
    if (0 != subcmd_len())                                      printf("%s", generate_subcommand_help())
    printf("\n")
}

NR==4{    print_helpdoc() > "/dev/stderr";    exit_now(0);    }
