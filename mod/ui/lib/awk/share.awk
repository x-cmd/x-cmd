BEGIN{
    false = 0
    FALSE = 0
    true = 1
    TRUE = 1
    S = "\001"
    T = "\002"
    L = "\003"
    A = "\004"
}

BEGIN{
    max_row_size_prev = 0
    max_col_size_prev = 0
    max_row_size = 1
    max_col_size = 1
}

function update_width_height(width, height) {
    max_row_size_prev = max_row_size
    max_col_size_prev = max_col_size

    max_row_size = height
    max_col_size = width
    # TODO: if row less than 10 rows, we should exit.
    max_row_in_page = max_row_size - 10
}

function is_height_change() {
    if ( max_row_size_prev != max_row_size ) {
        return true
    } else {
        return false
    }
}

function try_update_width_height(text){
    if (text !~ /^R:/) {
        return false
    }

    split(text, arr, ":")
    update_width_height(arr[3], arr[4])
    return is_height_change()
}

# Section: Buffer
BEGIN {
    BUFFER = ""
}

function bufferln(data){
    if (BUFFER == "") BUFFER = data
    else BUFFER = BUFFER "\n" data
}

function buffer_append(data){
    BUFFER = BUFFER data
}

function buffer_clear(          buf){
    buf = BUFFER
    BUFFER = ""
    return buf
}

function buffer_get(          buf){
    return BUFFER
}
# EndSection


# Section: utilities

# function send_update(msg){
#     # mawk
#     if (ORS == "\n") {
#         # gsub("\n", "\001", msg)
#         gsub(/\n/, "\001", msg)
#     }

#     printf("%s %s %s" ORS, "UPDATE", max_col_size, max_row_size)
#     printf("%s" ORS, msg)

#     fflush()
# }

function send_update(msg){
    printf("%s %s %s\n", "UPDATE", max_col_size, max_row_size)
    printf("%s" "\n" "\003\002\005" "\n", msg)

    fflush()
}

# function send_env(var, value){
#     # mawk
#     if (ORS == "\n") {
#         gsub(/\n/, "\001", value)
#     }

#     printf("%s %s" ORS, "ENV", var)
#     printf("%s" ORS, value)
#     fflush()
# }

function send_env(var, value){
    printf("%s %s\n", "ENV", var)
    printf("%s" "\n" "\003\002\005" "\n", value)

    fflush()
}

# EndSection

# Section: ctrl_help
BEGIN{
    NEWLINE = "\n"
    UI_KEY="\033[7m"
    UI_END="\033[0m"
    # L = "len"

    # CTRL_HELP_ITEM_ARR

    CTRL_HELP_TOGGLE_VAR = false
}


function ctrl_help_item_stringify(key, msg) {
    return UI_KEY key UI_END " " msg "; "
}

function ctrl_help_item_put(k, v) {
    l = CTRL_HELP_ITEM_ARR[ L ]
    # if (l  == "" ) l = 0
    l = l + 1
    CTRL_HELP_ITEM_ARR[ l "K" ] = k
    CTRL_HELP_ITEM_ARR[ l "V" ] = v
    CTRL_HELP_ITEM_ARR[ L ] = l
}

function ctrl_help_toggle(){
    CTRL_HELP_TOGGLE_VAR = 1 - CTRL_HELP_TOGGLE_VAR
    return CTRL_HELP_TOGGLE_VAR
}

function ctrl_help_toggle_state(){
    return CTRL_HELP_TOGGLE_VAR
}

function ctrl_help_get(     i, l,_msg){
    _msg = ctrl_help_item_stringify("q", "to quit")

    if (CTRL_HELP_TOGGLE_VAR == true) {
        _msg = ctrl_help_item_stringify("h", "close help") _msg "\n"
        l = CTRL_HELP_ITEM_ARR[ L ]
        for (i=1; i<=l; ++i) {
            _msg = _msg ctrl_help_item_stringify( CTRL_HELP_ITEM_ARR[i "K"], CTRL_HELP_ITEM_ARR[i "V"] )
        }
    } else {
        _msg = ctrl_help_item_stringify("h", "open  help") _msg
    }
    return _msg
}

# EndSection

# Section: ctrl state
function ctrl_state_init( obj, min, max, _key_prefix ) {
    obj[ _key_prefix "val" ] = min
    obj[ _key_prefix "min" ] = min
    obj[ _key_prefix "max" ] = max
}

function ctrl_state_inc( obj, _key_prefix,   m, v ){
    v = obj[ _key_prefix "val" ]
    m = obj[ _key_prefix "max" ]
    if (v < m) {
        v += 1
        obj[ _key_prefix "val" ] = v
    }
    return v
}

# TODO: check
function ctrl_state_add( obj, val, _key_prefix,     mi, ma, mr, v ){
    v = obj[ _key_prefix "val" ]
    ma = obj[ _key_prefix "max" ]
    mi = obj[ _key_prefix "min" ]
    v += val
    if (v < mi) v = mi
    else if (v > ma) v = ma
    obj[ _key_prefix "val" ] = v
    return v
}

function ctrl_state_dec( obj, _key_prefix,  m, v ){
    v = obj[ _key_prefix "val" ]
    m = obj[ _key_prefix "min" ]
    if (v > m) {
        v -= 1
        obj[ _key_prefix "val" ] = v
    }
    return v
}

function ctrl_state_get( obj, _key_prefix ){
    return obj[ _key_prefix "val" ]
}

function ctrl_state_set( obj, val, _key_prefix ){
    obj[ _key_prefix "val" ] = val
}

# EndSection

# Section: ctrl rstate
function ctrl_rstate_init( obj, min, max, _key_prefix ) {
    obj[ _key_prefix "val" ] = min
    obj[ _key_prefix "min" ] = min
    obj[ _key_prefix "max" ] = max
}

function ctrl_rstate_inc( obj, _key_prefix,             m ){
    v = obj[ _key_prefix "val" ]
    m = obj[ _key_prefix "max" ]
    if (v < m) {
        v += 1
    } else {
        v = obj[ _key_prefix "min" ]
    }
    obj[ _key_prefix "val" ] = v
    return v
}


# BEGIN{
#     ctrl_rstate_init(a, 3, 10)
#     print ctrl_rstate_add(a, 12)
#     print ctrl_rstate_add(a, -12)
#     print ctrl_rstate_add(a, -3)
#     print ctrl_rstate_add(a, +3)
# }


function ctrl_rstate_add( obj, val, _key_prefix,     mi, ma, mr, v ){
    v = ctrl_rstate_get( obj, _key_prefix )
    ma = obj[ _key_prefix "max" ]
    mi = obj[ _key_prefix "min" ]
    v += val - mi
    mr = ma - mi + 1
    v = v % mr
    if (v < 0) v = v + mr
    v += mi
    obj[ _key_prefix "val" ] = v
    return v
}

function ctrl_rstate_dec( obj, _key_prefix,           m, v ){
    v = ctrl_rstate_get( obj, _key_prefix )
    m = obj[ _key_prefix "min" ]
    if (v > m) {
        v -= 1
    } else {
        v = obj[ _key_prefix "max" ]
    }
    obj[ _key_prefix "val" ] = v
    return v
}

function ctrl_rstate_get( obj, _key_prefix ){
    # if (( obj[ "val" ] == "" )       obj[ "val" ] = obj[ "min" ]
    return obj[ _key_prefix "val" ]
}

function ctrl_rstate_set( obj, val, _key_prefix ){
    obj[ _key_prefix "val" ] = val
}

function ctrl_rstate_addchar( obj, val, _key_prefix ) {
    v = obj[ _key_prefix "val" ] val
    if ( ( int(v) >= int(obj[ _key_prefix "min" ]) ) && ( int(v) <= int(obj[ _key_prefix "max" ] )) ) {
        ctrl_rstate_set( obj,  v )
    }
}

function ctrl_rstate_delchar( obj, _key_prefix ) {
    v = obj[ _key_prefix "val" ]
    ctrl_rstate_set( obj, substr(v, 1, length(v) - 1), _key_prefix )
}

function ctrl_rstate_handle_char( obj, char_type, char_value, _key_prefix ) {
    if (char_type == "ascii-delete") {
        ctrl_rstate_delchar( obj, _key_prefix )
    } else if (index("0123456789", char_value) > 0) {
        ctrl_rstate_addchar( obj, char_value, _key_prefix )
    } else {
        return false
    }
    return true
}

# EndSection

# Section: ctrl sw
function ctrl_sw_init( obj, bool ) {
    if (bool != true) {
        obj[ 1 ] = false
    } else {
        obj[ 1 ] = true
    }
}

function ctrl_sw_toggle( obj ) {
    obj[ 1 ] = 1- obj[ 1 ]
    return obj[ 1 ]
}

function ctrl_sw_get( obj ) {
    return obj[ 1 ]
}
# EndSection

# Section: ctrl lineedit
function ctrl_lineedit_init( obj, _key_prefix ) {
    obj[ _key_prefix ] = ""
}

function ctrl_lineedit_handle( obj, _key_prefix, char_type, char_value,  d ) {
    d = obj[ _key_prefix ]
    if (char_type == "special") return
    if (char_type == "ascii-delete") {
        obj[ _key_prefix ] = substr(d, 1, length(d) - 1)
    } else {
        obj[ _key_prefix ] = d char_value
    }
}

function ctrl_lineedit_get( obj, _key_prefix ) {
    return obj[ _key_prefix ]
}

function ctrl_lineedit_put( obj, val, _key_prefix ) {
    obj[ _key_prefix ] = val
}
# EndSection

# Section: ctrl windows movement

function ctrl_win_init(  obj, _key_prefix, min, max, size ){
    obj[ _key_prefix "min" ]    = min
    obj[ _key_prefix "max" ]    = max
    obj[ _key_prefix "size" ]   = size
    obj[ _key_prefix "off" ]    = min

    _val = obj[ _key_prefix "val" ]
    if (_val == "") {
        obj[ _key_prefix "val" ]    = min
    } else {
        obj[ _key_prefix "off" ]    = _val
    }
}

function ctrl_win_inc( obj, _key_prefix,  _val, _max, _off, _size ) {
    _val = obj[ _key_prefix "val" ]
    _max = obj[ _key_prefix "max" ]
    _off = obj[ _key_prefix "off" ]
    _size = obj[ _key_prefix "size" ]
    _val += 1
    if (_val > _max)                    _val = _max
    if (_val >= _off+_size)             obj[ _key_prefix "off" ] = _off + _size
    obj[ _key_prefix "val" ] = _val
    return _val
}

function ctrl_win_dec( obj, _key_prefix,  _val, _min, _off, _size ) {
    _val = obj[ _key_prefix "val" ]
    _min = obj[ _key_prefix "min" ]
    _off = obj[ _key_prefix "off" ]
    _size = obj[ _key_prefix "size" ]
    _val -= 1
    if (_val < _min)             _val = _min
    if (_val < _off)             obj[ _key_prefix "off" ] = _off - _size
    obj[ _key_prefix "val" ] = _val
    return _val
}

function ctrl_win_rinc( obj, _key_prefix,  _val, _max, _min, _off, _size ) {
    _val = obj[ _key_prefix "val" ]
    _min = obj[ _key_prefix "min" ]
    _max = obj[ _key_prefix "max" ]
    _off = obj[ _key_prefix "off" ]
    _size = obj[ _key_prefix "size" ]
    _val += 1
    if (_val > _max) {
        _val = _min
        if (_val < _off)  obj[ _key_prefix size"off" ] = _min
    }
    if (_val >= _off+_size)             obj[ _key_prefix "off" ] = _off + _size
    obj[ _key_prefix "val" ] = _val
    return _val
}

function ctrl_win_rdec( obj, _key_prefix,  _val, _min, _max, _off, _size ) {
    _val = obj[ _key_prefix "val" ]
    _min = obj[ _key_prefix "min" ]
    _max = obj[ _key_prefix "max" ]
    _off = obj[ _key_prefix "off" ]
    _size = obj[ _key_prefix "size" ]
    _val -= 1
    if (_val < _min) {
        _val = _max
        if (_val >= _off+_size)  obj[ _key_prefix size"off" ] = _max - _size
    }
    if (_val < _off)             obj[ _key_prefix "off" ] = _off - _size
    obj[ _key_prefix "val" ] = _val
    return _val
}

function ctrl_win_val( obj, _key_prefix ){
    return obj[ _key_prefix "val" ]
}

function ctrl_win_begin( obj, _key_prefix ){
    return obj[ _key_prefix "off" ]
}

function ctrl_win_end( obj, _key_prefix ){
    return obj[ _key_prefix "off" ] + obj[ _key_prefix "size" ] - 1
}

function ctrl_win_set( obj, val, _key_prefix ){
    obj[ _key_prefix "val" ] = val
}


# EndSection

# Section: exit detect

BEGIN{
    final_command = ""
    if ( EXIT_CHAR_LIST == "" )  EXIT_CHAR_LIST = ",q,c,r,u,d,e,f,ENTER,"
}

function exit_with_elegant(command, item){
    final_command = command
    exit(0)
}

function exit_is_with_cmd(command, item){
    if (final_command == "") {
        return false
    } else {
        return true
    }
}

function exit_get_cmd(command, item){
    return final_command
}

# TODO: not well designed
# Maybe using some unseen character
function exit_if_detected( char_value, EXIT_CHAR_LIST ){
    if (index(EXIT_CHAR_LIST, "," char_value ",") > 0) return exit_with_elegant( char_value )
}

# EndSection

function judgment_of_regexp(obj, _key_prefix, val,     i){
    for (i=1; i<=obj[ _key_prefix L]; ++i) {
        if ( match( val, "^"obj[ _key_prefix L i ]"$") ) return true
    }
    return false
}

function is_regex(val){
    return (val ~ "^/.*/$") ? true : false
}

function judgment_of_regexp_or_candidate(obj, _key_prefix, _answer,     i, val){
    for (i=1; i<=obj[ _key_prefix L]; ++i) {
        val = obj[ _key_prefix L i ]
        if ( is_regex(val) ) {
            if ( match( _answer, "^"substr(val, 2, length(val)-2)"$") ) return true
        } else {
            if ( _answer == val ) return true
        }
    }
    return false
}

# Section: from awk

BEGIN{
    INPUT_STATE_STOP = 0
    INPUT_STATE_ONGOING = 1
    INPUT_STATE = 1 - INPUT_STATE_ONGOING

    INPUT_SECTION = 0
}

function input_consume( ){
    if (INPUT_STATE == INPUT_STATE_ONGOING) {
        if ($0 == "\003\003\003") {
            INPUT_STATE = INPUT_STATE_STOP
        }
        return ++state_idx
    }
    if ($0 == "\001\001\001") {
        state_idx = 0
        INPUT_STATE = INPUT_STATE_ONGOING
        return state_idx
    }
    return ""
}

function input_consume_multi( _tmp ){
    _tmp = input_consume()
    if (_tmp == "" )     return ""
    if ($0 == "\002\002\022") {
        INPUT_SECTION += 1
        state_idx = 0
        return state_idx
    }
    return _tmp
}

# EndSection

# Section: stack
function stack_length( obj,     l ){
    return obj[ L ] + 0
}

function stack_push( obj, elem,     l ){
    l = obj[ L ] + 1
    obj[ L ] = l
    obj[ l ] = elem
    return l
}

function stack_pop( obj,            l ){
    l = obj[ L ]
    if (l == 0) return
    obj[ L ] = l - 1
    return obj[ l ]
}

function stack_top( obj,     l ){
    return obj[ obj[ L ] + 0 ]
}

# EndSection

function display_ui_errormsg(data_len, rows, cols,          _data){
    if (data_len <= 0)              _data = "We couldn't find any data ..."
    if ((rows <= 0) || (cols <= 0)) _data = "Not enough rows or columns of terminal ..."
    if (_data != "" ) {
        _data = str_pad_center(_data, max_col_size)
        _data = th(TH_DATA_UNFIND, _data)
        return _data
    }
}