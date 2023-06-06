# Section: 4-Arguments and intercept for help and advise            5-DefaultValues
function print_optarg( optarg_id,            _option_default, _op, k, l ){
    _option_default = optarg_default_get( optarg_id )
    # Notice: Adding "\006" to distinguish whether _option_default is "" or null
    if (_option_default != "" && ! optarg_default_value_eq_require( _option_default ) )  printf("%s", "\006" _option_default)
    printf("\n")

    _op = oparr_get( optarg_id, 1 )
    if ( _op == "=~" || _op == "=" ) {
        printf( "%s", _op )
        l = oparr_len( optarg_id )
        for ( k=2; k<=l; ++k )  printf("%s", "\006" oparr_get( optarg_id, k ) )
    }
    printf("\n")
}

function ls_option(         i, j, _tmp_len, _option_id, _tmp, _option_argc){
    for (i=1; i<=advise_len(); ++i) {
        _tmp_len = split(advise_get( i ), _tmp)
        _option_id = _tmp[1]
        advise_map[ _option_id ] = str_trim( advise_map[ _option_id ] " " str_join( " ", _tmp, "", 2, _tmp_len ) )
    }

    for (i=1; i<=namedopt_len(); ++i) {
        _option_id = namedopt_get( i )
        printf("%s\n%s\n", _option_id, option_desc_get( _option_id ))

        _option_argc = option_argc_get( _option_id )
        for(j=1; j<=_option_argc; ++j)   print_optarg( _option_id SUBSEP j )

        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }

    for (i=1; i<=flag_len(); ++i) {
        _option_id = flag_get( i )
        printf("%s\n%s\n\n\n\n", _option_id, option_desc_get( _option_id ))
    }

    for (i=1; i <= restopt_len(); ++i) {
        _option_id = restopt_get( i )
        printf("%s\n%s\n", _option_id, option_desc_get( _option_id ))
        print_optarg( _option_id )
        printf("%s\n", (advise_map[ _option_id ] != "") ? advise_map[_option_id] : "")
    }
}

function ls_option_name(         i, j, _option_id, _option_argc){
    for (i=1; i<=namedopt_len(); ++i) {
        _option_id = namedopt_get( i )
        printf("%s\n", option_name_get_without_hyphen( _option_id ) )
    }
    for (i=1; i<=flag_len(); ++i) {
        _option_id = flag_get( i )
        printf("%s\n", option_name_get_without_hyphen( _option_id ) )
    }

}

function ls_subcmd(         i,_cmd_name){
    for (i=1; i <= subcmd_len(); ++i) {
        _cmd_name = subcmd_id( i )
        printf("%s\n%s\n", _cmd_name, subcmd_desc_by_id( _cmd_name ) )
    }
}

function _param_list_subcmd(         i, _tmp){
    for (i=1; i <= subcmd_len(); ++i) {
        _tmp = subcmd_id( i )
        gsub(/\|/, "\n", _tmp)
        printf("%s\n", _tmp )
    }
}

NR==4{
    if( arg_arr[1] == "_param_has_subcmd" ){
        for(i=1; i<=subcmd_len(); ++i) if( subcmd_id( i ) == arg_arr[2] ) exit 0
        exit 1
    }
    else if( arg_arr[1] == "_param_list_subcmd" )                                         _param_list_subcmd()
    else if( arg_arr[1] == "_ls_subcmd" )                                                 ls_subcmd()
    else if( arg_arr[1] == "_ls_option" )                                                 ls_option()
    else if( arg_arr[1] == "_ls_option_name" )                                            ls_option_name()
    else if( arg_arr[1] == "_ls_option_subcmd" ){
        ls_option()
        printf("---------------------\n")
        ls_subcmd()
        printf("---------------------\n")
        for(i=1; i <= arg_arr[ L ]; ++i)      printf("%s\n", arg_arr[i])
    }
    else exit 1

    exit 0
}
