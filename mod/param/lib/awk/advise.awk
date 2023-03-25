BEGIN{  SSS = "\n";  ___X_CMD_PARAM_ADIVSE_NAME = ENVIRON[ "___X_CMD_PARAM_ADIVSE_NAME" ]; }
function AJADD( s ){    ADVISE_JSON = ADVISE_JSON s SSS;    }
function CDADD( s ){    CODE = CODE s "\n"; }

function swrap( s ){  return "\"" s "\""; }

function generate_advise_json_value_candidates_by_rules( optarg_id, advise_map,        op, _default, i, l ){
    AJADD("{");
    AJADD( swrap("#desc") ); AJADD( ":" ); AJADD( swrap(option_desc_get( optarg_id )) );

    if (advise_map[ optarg_id ] != "")  {
        AJADD(","); AJADD( swrap("#exec") ); AJADD(":");                        AJADD( swrap(advise_map[ optarg_id ]) );
    }

    op = oparr_get( optarg_id, 1 )
    if (op == "=~") {
        AJADD(","); AJADD( swrap("#regex") ); AJADD(":")
        l = oparr_len( optarg_id ); AJADD("{")
        if (2 <= l)          { AJADD( swrap(oparr_get( optarg_id, 2 )) ); AJADD(":"); AJADD("\"\""); }
        for (i=3; i<=l; ++i) { AJADD(","); AJADD( swrap(oparr_get( optarg_id, i )) ); AJADD(":"); AJADD("\"\""); }
        AJADD("}")
    }

    if (op == "=") {
        AJADD(","); AJADD( swrap("#cand") ); AJADD(":");                        AJADD("["); AJADD( oparr_join_wrap( optarg_id, SSS "," SSS ) ); AJADD("]")
    }

    _default = optarg_default_get( optarg_id )
    if (_default != "" && ! optarg_default_value_eq_require( _default ) ) {
        AJADD(","); AJADD( swrap("#default") ); AJADD(":");                     AJADD( swrap( _default ) )
    }

    AJADD("}");
}

function generate_advise_json_subcmd(       i, l, subcmd_funcname, subcmd_invocation, _name_arr, _ret ){
    l = subcmd_len()
    if ( l <= 0 ) return
    AJADD("',"); AJADD( swrap("#subcmd_help_tip") ); AJADD(":"); AJADD("true"); AJADD("'");
    for ( i=1; i<=l; ++i ) {
        split(subcmd_id( i ), _name_arr, "|") # get the subcmd name list
        if( subcmd_map[ _name_arr[ 1 ], SUBCMD_FUNCNAME ] != "" )   subcmd_funcname = subcmd_map[ _name_arr[ 1 ], SUBCMD_FUNCNAME ] "_" _name_arr[ 1 ]
        else                                                        subcmd_funcname = "${X_CMD_ADVISE_FUNC_NAME}_" _name_arr[ 1 ]

        subcmd_invocation = sprintf("\\$( B=\"\\$( PARAM_SUBCMD_DEF=''; X_CMD_ADVISE_FUNC_NAME=%s %s _x_cmd_advise_json %s)\"; if [ -n \"\\$B\" ]; then printf \"%%s\" \"\\$B\"; else return 1; fi; )", subcmd_funcname, subcmd_funcname, qu1( subcmd_desc(i) ) )

        _ret = "'," SSS swrap(subcmd_id( i )) SSS ":" SSS "'"
        ADVISE_JSON = ADVISE_JSON SSS "A=\"\\${A}\"" _ret "\"" subcmd_invocation "\""
    }
}

function generate_advise_json_init_advise_map(advise_map,   i, tmp, _option_id, tmp_len){
    for ( i=1; i<=advise_len(); ++i ) {
        tmp_len = split(advise_get( i ), tmp)
        _option_id = tmp[1];     if ( option_get_id_by_alias( _option_id ) != "" )  _option_id = option_get_id_by_alias( _option_id )
        if ( _option_id !~ "^#" ){
            if ( match(_option_id, "\\|[0-9]+$") ) _option_id = substr(_option_id, 1, RSTART-1) S substr(_option_id, RSTART+1)
            else _option_id = _option_id S 1
        }
        advise_map[ _option_id ] = str_trim( str_join( " ", tmp, "", 2, tmp_len ) )
    }
}

function generate_advise_json_except_subcmd(      i, j, _option_id, _option_argc, advise_map, _synopsis_str ){
    generate_advise_json_init_advise_map( advise_map )

    AJADD( "{" )
    if (___X_CMD_PARAM_ADIVSE_NAME != "" ) {
        AJADD( swrap("#name") ); AJADD( ":" ); AJADD( "{" );
        AJADD( swrap( ___X_CMD_PARAM_ADIVSE_NAME ) ); AJADD( ":" ); AJADD( "null" );
        AJADD( "}" ); AJADD(",");
    }

    AJADD( swrap("#desc") ); AJADD( ":" ); AJADD( swrap( arg_arr[2] ) );

    for (i=1; i <= namedopt_len(); ++i) {
        _option_id       = namedopt_get( i )
        _option_argc     = option_arr[ _option_id L ]

        AJADD(","); AJADD( swrap(get_option_key_by_id(_option_id)) ); AJADD( ":" );
        AJADD( "{" );
        AJADD( swrap("#desc") ); AJADD(":"); AJADD( swrap( option_desc_get( _option_id ) ) )

        if ( _option_argc > 0 ) {
            if ( (_synopsis_str = get_option_synopsis_str(_option_id)) != "") {
                AJADD(","); AJADD( swrap("#synopsis") ); AJADD(":"); AJADD( swrap( _synopsis_str ))
            }
        }
        for ( j=1; j<=_option_argc; ++j ) {
            AJADD(",")
            AJADD( swrap( "#" j ) ); AJADD(":");                                generate_advise_json_value_candidates_by_rules( _option_id SUBSEP j, advise_map );
        }
        AJADD( "}" );
    }

    for (i=1; i <= flag_len() && _option_id = flag_get( i ); ++i) {
        AJADD(","); AJADD( swrap(get_option_key_by_id(_option_id)) ); AJADD(":");
        AJADD("{"); AJADD( swrap("#desc") ); AJADD(":"); AJADD( swrap(option_desc_get( _option_id )) ); AJADD("}")
    }

    for (i=1; i <= restopt_len() && _option_id = restopt_get( i ); ++i) {
        AJADD(",");
        if ( match(_option_id, "^#([0-9]+|n)\\|") ) {
            AJADD( swrap( substr(_option_id, RSTART+RLENGTH) ) ); AJADD( ":" );
            AJADD( "{" );
            AJADD( swrap("#desc") ); AJADD(":"); AJADD( swrap( option_desc_get( _option_id ) ) );
            AJADD(","); AJADD( swrap( "#1" ) ); AJADD( ":" );                   generate_advise_json_value_candidates_by_rules(_option_id, advise_map )
            AJADD( "}" );
        } else {
            AJADD( swrap( _option_id ) );  AJADD( ":" );                        generate_advise_json_value_candidates_by_rules(_option_id, advise_map )
        }
    }

    gsub("'", "'\\''", ADVISE_JSON );   ADVISE_JSON = "'" ADVISE_JSON "'"
}

function generate_advise_json(){
    generate_advise_json_except_subcmd()
    generate_advise_json_subcmd( )
    AJADD( "'\n}';" )
    CDADD( " A=" ADVISE_JSON )

    gsub("\"", "\\\"", CODE)
    CODE = sprintf("( set -o errexit; %s printf \\\"%%s\\\" \\\"\\$A\\\"; )", CODE  )
    CODE = "eval \"" CODE "\""
    # debug(CODE)
    printf("%s", CODE)
}

NR==4{   generate_advise_json();     exit_now(1);    }