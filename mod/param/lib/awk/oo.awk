
# Section: code facility
function code_print(){
    print CODE
}

function code_append(code){
    CODE=CODE "\n" code
}

# TODO: check whether all of the invocator correctly quote the value
function code_append_assignment(varname, value, is_allow_null) {
    code_append( "local " varname " >/dev/null 2>&1" )
    if ((value == "") && (is_allow_null != true)) code_append( "unset " varname ";")
    else code_append( varname "=" qu1( value ) ";")
}

function code_query_append(varname, description, typestr, current_val){
    code_append( "local " varname " >/dev/null 2>&1" )
    QUERY_CODE=QUERY_CODE " \"--\" \\" "\n" varname " " qu(description) " " qu(current_val) " " typestr
}

function code_query_append_by_optionid_optargid( varname, option_id, optarg_id, current_val ){
    code_query_append( varname, option_desc_get( option_id ), oparr_join_quoted(optarg_id), current_val )
}

# EndSection

# Section: type

function type_add_line(line_trimed,                 _name){
    match(line_trimed, /^[\-_A-Za-z0-9]+/)
    if (RLENGTH <= 0) {
        panic_param_define_error("Should not happned for type lines\nerror type: '" line_trimed"'")
    }

    _name = substr(line_trimed, 1, RLENGTH)
    type_arr[ _name ] = line_trimed
}

function type_rule_by_name( name ){
    return type_arr[ name ]
}

# EndSection

# Section: subcmd

BEGIN{
    subcmd_arr[ L ] = 0
    HAS_SUBCMD = false
    SUBCMD_FUNCNAME = "funcname"
}

function subcmd_add_line( line_trimed, subcmd_funcname,                 _id, _name_arr, _name_arr_len, i, idx){
    if (! match(line_trimed, "^[A-Za-z0-9_\\|-]+")) {
        panic_param_define_error( "Expect subcommand in the first token, but get:\n" line_trimed )
    }

    HAS_SUBCMD = true

    idx = subcmd_len() + 1
    subcmd_arr[ L ] = idx

    _id = substr( line_trimed, 1, RLENGTH )
    subcmd_arr[ idx ] = _id
    subcmd_map[ _id ] = str_unquote( str_trim( substr( line_trimed, RLENGTH+1 ) ) )
    subcmd_map[ _id, SUBCMD_FUNCNAME ] = subcmd_funcname

    _name_arr_len = split(_id, _name_arr, "|")
    for (i=1; i<=_name_arr_len; i++) {
        subcmd_id_lookup[ _name_arr[ i ] ] = _id
    }
}

function subcmd_id( i ){
    return subcmd_arr[ i ]
}

function subcmd_len(){
    return subcmd_arr[ L ]
}

function subcmd_desc( idx ){
    return subcmd_map[ subcmd_arr[idx] ]
}

function subcmd_desc_by_id( id ){
    return subcmd_map[ id ]
}

function subcmd_id_by_name( name ){
    return subcmd_id_lookup[ name ]
}

function subcmd_exist_by_id( id ){
    return subcmd_map[ id ] != ""
}


# EndSection

# Section: advise
function advise_add( line ){    return arr_push( advise_arr, line );    }
function advise_get( idx ){     return arr_get(  advise_arr, idx );  }
function advise_len( ){         return arr_len(  advise_arr ); }

# EndSection

BEGIN{
    namedopt_id_list[ L ] = 0
    restopt_id_list[ L ] = 0
}

# Section: option

BEGIN {
    # OPTION_ARGC = "num" # Equal  L
    # OPTION_SHORT = "shoft"
    # OPTION_TYPE = "type"

    OPTION_M = "M"
    OPTION_NAME = "varname"
    OPTION_DESC = "desc"

    option_arr[ L ]=0
}

function option_argc_get( id ){ return option_arr[ id L ]; }
function option_argc_set( id, argc ){   option_arr[ id L ] = argc; }

function option_multarg_disable( id ){ option_arr[ id, OPTION_M ] = 0; }
function option_multarg_enable( id ){ option_arr[ id, OPTION_M ] = 1; }
function option_multarg_get( id ){ return option_arr[ id, OPTION_M ]; }

function option_multarg_is_enable( id ){ return option_arr[ id, OPTION_M ] == 1; }

function option_name_set( id, name ){ option_arr[ id, OPTION_NAME ] = name; }
function option_name_get( id ){ return option_arr[ id, OPTION_NAME ]; }

function option_name_get_without_hyphen( id,    _name ){
    _name = option_arr[ id, OPTION_NAME ]
    gsub(/^--?/, "", _name)
    return _name
}

function option_desc_set( id, desc ){ option_arr[ id, OPTION_DESC ] = desc; }
function option_desc_get( id ){ return option_arr[ id, OPTION_DESC ]; }

function option_get_id_by_alias( alias ){
    return option_alias_2_option_id[ alias ]
}

function option_set_alias( id, alias ){
    return option_alias_2_option_id[ alias ] = id
}

function option_exist_by_alias( alias ){
    return ( option_alias_2_option_id[ alias ] != "" )
}

function option_assign_count_inc( option_id ){
    return option_assignment_count[ option_id ] = option_assignment_count[ option_id ] + 1      # option_assignment_count[ _option_id ] can be ""
}

function option_assign_count_get( option_id     ){
    return option_assignment_count[ option_id ]
}


# EndSection

# Section: optarg

BEGIN{
    OPTARG_NAME = "val_name"
    # OPTARG_TYPE = "val_type"

    OPTARG_DEFAULT = "val_default"

    # TODO: introduce OPTARG_DEFAULT_UNSET_VALUE
    OPTARG_DEFAULT_REQUIRED_VALUE = "\001"

}

function optarg_name_set( id, name ){ option_arr[ id, OPTARG_NAME ] = name; }
function optarg_name_get( id ){ return option_arr[ id, OPTARG_NAME ]; }

function optarg_default_get( id ){ return option_arr[ id, OPTARG_DEFAULT ]; }
function optarg_default_set( id, value ){ option_arr[ id, OPTARG_DEFAULT ] = value; }

BEGIN {
    EXISTS_REQUIRED_OPTION = false
}

function optarg_default_set_required( id ){
    EXISTS_REQUIRED_OPTION = true
    option_arr[ id, OPTARG_DEFAULT ] = OPTARG_DEFAULT_REQUIRED_VALUE;
}

function option_exist_required(){       # Seemed Not Used
    return EXISTS_REQUIRED_OPTION
}

function optarg_default_value_eq_require( value ){ return value == OPTARG_DEFAULT_REQUIRED_VALUE; }

# EndSection

# Section: oparr

BEGIN{
    OPTARG_OPARR = "val_oparr"
}

function oparr_get( optarg_id, idx ){
    return option_arr[ optarg_id, OPTARG_OPARR, idx ]
}

function oparr_set( optarg_id, idx, value ){
    option_arr[ optarg_id, OPTARG_OPARR, idx ] = value
}

function oparr_len( optarg_id ){
    return option_arr[ optarg_id, OPTARG_OPARR L ]
}

function oparr_add( optarg_id, value,   l ){
    l = oparr_len( optarg_id ) + 1
    option_arr[ optarg_id, OPTARG_OPARR L ] = l
    option_arr[ optarg_id, OPTARG_OPARR, l ] = value
}


function oparr_join_plain(optarg_id,            _oparr_keyprefix){
    _oparr_keyprefix = optarg_id S OPTARG_OPARR
    return " " str_join( " ", option_arr, _oparr_keyprefix S, 1, option_arr[ _oparr_keyprefix L ] )
}


function oparr_join_quoted( optarg_id , start,             _index, _len, _ret, oparr_keyprefix, op ){
    oparr_keyprefix = optarg_id SUBSEP OPTARG_OPARR
    _ret = ""
    _len = option_arr[ oparr_keyprefix L ]
    op = option_arr[ oparr_keyprefix, 1 ]
    _ret = " " str_quote_if_unquoted( op )
    for ( _index=2; _index<=_len; ++_index ) {
        if (op == "=~") _ret = _ret " " str_quote_if_unquoted( "^" str_unquote_if_quoted( option_arr[ oparr_keyprefix, _index ] ) "$" )
        else _ret = _ret " " str_quote_if_unquoted( option_arr[ oparr_keyprefix, _index ] )
    }
    return _ret
}

function oparr_join_wrap(optarg_id, sep,           _oparr_keyprefix){
    _oparr_keyprefix = optarg_id S OPTARG_OPARR
    return str_joinwrap( sep,  "\"", "\"", option_arr, _oparr_keyprefix S, 2, oparr_len( optarg_id ) )
}

# EndSection

# Section: restopt list
function restopt_add_id( id,    _tmp ){
    _tmp = restopt_id_list[ L ] + 1
    restopt_id_list[ L ] = _tmp
    restopt_id_list[ _tmp ] = id
}

function restopt_len(){
    return restopt_id_list[ L ]
}

function restopt_get( idx ){
    return restopt_id_list[ idx ]
}
# EndSection

# Section: namedopt
function namedopt_add_id( id,    _tmp ){
    _tmp = namedopt_id_list[ L ] + 1
    namedopt_id_list[ L ] = _tmp
    namedopt_id_list[ _tmp ] = id
}

function namedopt_len(){
    return namedopt_id_list[ L ]
}

function namedopt_get( idx ){
    return namedopt_id_list[ idx ]
}

function namedopt_clone( dst ){
    arr_clone( namedopt_id_list, dst )
}
# EndSection

# Section: flag
function flag_add_id( id,    _tmp ){
    _tmp = flag_id_list[ L ] + 1
    flag_id_list[ L ] = _tmp
    flag_id_list[ _tmp ] = id
}

function flag_len(){
    return flag_id_list[ L ]
}

function flag_get( idx ){
    return flag_id_list[ idx ]
}

function flag_clone( dst ){
    arr_clone( flag_id_list, dst )
}
# EndSection
