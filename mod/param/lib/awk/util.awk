BEGIN {
    false = 0;  true = 1
    # L-EN   ="len"
    # K-SEP  = "\034"

    S = SUBSEP # "\001"
    T = "\002"
    L = "\003"

    EXIT_CODE = 0
}

# Section: panic and debug and exit

BEGIN{
    if (IS_TTY == true) {
        FG_RED        = "\033[31m"
        FG_LIGHT_RED  = "\033[91m"
        FG_BLUE       = "\033[36m"
        FG_YELLOW     = "\033[33m"
        UI_END        = "\033[0m"
    }
}


function exit_now(code){
    EXIT_CODE = code
    exit code
}

function exit_print(exit_code){
    print "return " exit_code " 2>/dev/null || exit " exit_code
    exit_now( exit_code )
}

function panic_error(msg){
    if( DRYRUN_FLAG == true ){
        print "return 1"
        exit_now(1)
    }
    print FG_LIGHT_RED "error: " UI_END msg "\nFor more information try " FG_BLUE "--help" UI_END > "/dev/stderr"
    print "return 1 2>/dev/null || exit 1 2>/dev/null"
    exit_now(1)
}

function panic_param_define_error( msg ){
    print FG_LIGHT_RED "param define error: " UI_END msg "\nFor more information try " FG_BLUE "--help" UI_END > "/dev/stderr"
    # "For more information try to read the demo in " FG_BLUE "https://gitee.com/x-bash/param/blob/main/.x-cmd/testcases/v0_test"
    print "return 1 2>/dev/null || exit 1 2>/dev/null"
    exit_now(1);
}

function panic_invalid_argument_error(arg_name){
    panic_error("Option unexpected, or invalid in this context: '" FG_YELLOW arg_name UI_END "'")
}

# TODO: short
function panic_match_candidate_error(option_id, value, candidate_list) {
    panic_error(panic_match_candidate_error_msg(option_id, value, candidate_list))
}

function panic_match_candidate_error_msg(option_id, value, candidate_list) {
    return ("Fail to match any candidate, option '" FG_YELLOW get_option_string(option_id) UI_END "' the part of value is '" FG_LIGHT_RED value UI_END "'\n" candidate_list)
}

function panic_match_regex_error(option_id, value, regex) {
    panic_error(panic_match_regex_error_msg(option_id, value, regex))
}

function panic_match_regex_error_msg(option_id, value, regex) {
    return ("Fail to match any regex pattern, option '" FG_YELLOW get_option_string(option_id) UI_END "' the part of value is '" FG_LIGHT_RED value UI_END "'\n" regex )
}

function panic_required_value_error(option_id) {
    panic_error(panic_required_value_error_msg(option_id))
}

function panic_required_value_error_msg(option_id) {
    return ("Option require value, but none was supplied: '" FG_YELLOW get_option_string(option_id) UI_END "'")
}

function debug(msg){
    print FG_RED msg UI_END > "/dev/stderr"
}

# EndSection

# option_string is a string of option, each option is separated by ','
# example:
#   1. --option1,-o1
#   2. --option1,-o1 <arg1> <arg2> ...
function get_option_key_by_id(option_id){
    gsub("\\|m", "", option_id)
    if (match(option_id, "\\|-") && ( option_id !~ "^-") ) return substr( option_id, RSTART+1)
    return option_id
}

function get_option_synopsis_str(option_id,        l, i, _str, _argument_type){
    l = option_arr[ option_id L ]
    for ( i=1; i<=l; ++i ) {
        # BUG
        if ( (_argument_type = option_arr[ option_id S i S OPTARG_NAME ]) == "") return ""
        _str = _str (( _str != "" ) ? " <" : "<" ) _argument_type ">"
    }
    return _str
}

function get_option_string(option_id,           _option_string, _option_synopsis){
    _option_string = get_option_key_by_id( option_id )
    gsub("\\|", ",", _option_string)
    _option_synopsis = ( (_option_synopsis = get_option_synopsis_str(option_id)) != "" ) ? " " _option_synopsis : ""
    return _option_string _option_synopsis
}

function is_interactive(){
    return IS_INTERACTIVE == 1
}

