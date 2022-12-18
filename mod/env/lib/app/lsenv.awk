
# Section: view
BEGIN {
    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("ENTER", "for enter")
}

function view_calcuate_geoinfo(){
    if ( VIEW_BODY_ROW_SIZE >= MAX_DATA_ROW_NUM ) return
    if ( ctrl_help_toggle_state() == true )         VIEW_BODY_ROW_SIZE = max_row_size - 9 - 1
    else                                            VIEW_BODY_ROW_SIZE = max_row_size - 8 - 1
}

function view(      _component_help, _component_body){
    view_calcuate_geoinfo()

    _component_help         = view_help()
    _component_body         = view_body()

    send_update( _component_help "\n" _component_body  )
}

function view_help(){
    return sprintf("%s", th_help_text( ctrl_help_get() ) )
}

function view_body_info_for_dir(view_grid, _selected_keypath,         i, l, _selected_index_of_this_column, _content){
    l = data[ _selected_keypath L]
    _selected_index_of_this_column = ctrl_win_val( treectrl, _selected_keypath )
    _max_len = data[ _selected_keypath A "MAX_LEN" ] + 2
    for (i=1; i<=l; ++i) {
        _content = str_pad_right( data[ _selected_keypath L i ], _max_len)
        if ( _selected_index_of_this_column == i ) _content = th(TH_LSENV_ITEM_UNFOCUSED_SELECT, _content)
        else _content = th(TH_CATSEL_ITEM_UNFOCUSED_UNSELECT, _content)
        view_grid[ i S 0 ] = _content
    }
    return _max_len
}

function view_body_info_for_file(view_grid, _selected_keypath, _info, _max_len ) {
    _info = data[ _selected_keypath A "INFO" ]
    view_grid[ 1 S 0 ] = _info
    _max_len = wcswidth(_info)
    return _max_len
}


function view_body_cal_beginning_col( info_view_maxlen,     _col_end, _col_size, i, _kp, _len ){
    _col_size = max_col_size - info_view_maxlen - 2
    _col_end = stack_length( treectrl )
    for ( i=_col_end; i>=1; --i ) {
        _kp = treectrl[ i ]
        _len = data[ _kp A "MAX_LEN" ] + 2
        if (_col_size < _len)   return i+1
        _col_size -= _len
    }
    return 1
}

function view_body_info( view_grid,             _selected, _selected_keypath ){
    _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
    _selected_keypath = cur_keypath S _selected
    if ( data[ _selected_keypath L ] > 0 ) return view_body_info_for_dir(  view_grid, _selected_keypath )
    return                                        view_body_info_for_file( view_grid, _selected_keypath )
}

function view_body_show(view_grid, info_view_maxlen, _col_len,                _return, i, _selected, _selected_keypath, _view_info_grid ){

    _return = ui_str_rep(" ", _col_len + 4) "┌" ui_str_rep("─", info_view_maxlen) "┐"
    for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        if ( data[ _selected_keypath L ] < 1 )                     _view_info_grid = th(TH_LSENV_INFO, str_pad_right(view_grid[ i S 0 ], info_view_maxlen))
        else                                                       _view_info_grid = str_pad_right(view_grid[ i S 0 ], info_view_maxlen)
        _return = _return UI_END "\n" "  " view_grid[ i ] "  " "│" _view_info_grid "│"
    }
    _return = _return UI_END "\n" ui_str_rep(" ", _col_len + 4) "└" ui_str_rep("─", info_view_maxlen) "┘"
    return _return
}

function view_body( view_grid,                  _info_view_maxlen, _col_start, _col_len, _col_size, j, i, _kp, _offset_for_this_column, _selected_index_of_this_column, _max_col_len, _i_for_this_column, _tmp, _content ){
    _info_view_maxlen = view_body_info( view_grid )
    _col_start = view_body_cal_beginning_col( _info_view_maxlen )
    _col_size  = stack_length( treectrl )

    for (j=_col_start; j<=_col_size; ++j) {
        _kp = treectrl[ j ]
        _offset_for_this_column = ctrl_win_begin( treectrl, _kp )
        _selected_index_of_this_column = ctrl_win_val( treectrl, _kp )
        _max_col_len = data[ _kp A "MAX_LEN" ] + 2
        _col_len = _col_len + _max_col_len

        for (i=1; i<=VIEW_BODY_ROW_SIZE; ++i) {
            _i_for_this_column = _offset_for_this_column + i - 1
            if (_i_for_this_column > data[ _kp L]) {
                view_grid[ i ] = view_grid[ i ] ui_str_rep(" ", _max_col_len)
                continue
            }

            _tmp = data[ _kp L _i_for_this_column ]
            _content = str_pad_right( _tmp, _max_col_len)
            if (_kp == cur_keypath) {
                STYLE_LSENV_SELECTED      =   TH_LSENV_ITEM_FOCUSED_SELECT
                STYLE_LSENV_UNSELECTED    =   TH_LSENV_ITEM_FOCUSED_UNSELECT
            } else {
                STYLE_LSENV_SELECTED      =   TH_LSENV_ITEM_UNFOCUSED_SELECT
                STYLE_LSENV_UNSELECTED    =   TH_LSENV_ITEM_UNFOCUSED_UNSELECT
            }
            if ( is_expandable( _kp S _tmp ) == true )                      _content = th(TH_LSENV_DIRECTORY,    _content)
            if ( _selected_index_of_this_column == _i_for_this_column )     _content = th(STYLE_LSENV_SELECTED,    _content)
            else                                                            _content = th(STYLE_LSENV_UNSELECTED,  _content)
            view_grid[ i ] = view_grid[ i ] _content
        }
    }

    return view_body_show( view_grid, _info_view_maxlen, _col_len )
}

# EndSection

# Section: ctrl
function get_view_body_row_size() {
    VIEW_BODY_ROW_SIZE = max_row_size - 10
    if ( VIEW_BODY_ROW_SIZE > MAX_DATA_ROW_NUM )     VIEW_BODY_ROW_SIZE = MAX_DATA_ROW_NUM
    if ( VIEW_BODY_ROW_SIZE < 5)     VIEW_BODY_ROW_SIZE = 5
    return VIEW_BODY_ROW_SIZE
}

function ctrl(char_type, char_value,        _selected, _selected_keypath ){
    exit_if_detected( char_value, ",q,ENTER," )

    if (char_value == "h")                               return ctrl_help_toggle()
    if (char_value == "UP")                              return ctrl_win_rdec( treectrl, cur_keypath )
    if (char_value == "DN")                              return ctrl_win_rinc( treectrl, cur_keypath )

    if ((char_value == "LEFT") && (stack_length( treectrl ) != 1)) {
        stack_pop( treectrl )
        cur_keypath = stack_top( treectrl )
        return
    }

    if (char_value == "RIGHT") {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        _selected_keypath = cur_keypath S _selected
        if ( data[ _selected_keypath L ] < 1 ) return
        cur_keypath = _selected_keypath
        stack_push( treectrl, cur_keypath )
        return
    }
}

# EndSection

# Section: cmd source
NR==1{
    try_update_width_height( $0 )

    cur_keypath = "."
    ( CANDIDATE != "" ) && cur_keypath = cur_keypath S CANDIDATE
    get_data( cur_keypath )
    stack_push( treectrl, cur_keypath )
    prepare_selected_item_data()
    view()
}

NR>1{
    if ( try_update_width_height( $0 ) )    next
    # TODO: if it is update, recalculate the view.

    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    prepare_selected_item_data()
    view()
}
# EndSection

# Section: Functions differ in apps

function is_expandable( curkp ){
    return ( data[ curkp L ] > 0 ) ? true : false
    # return ( data[ curkp A "TYPE" ] == "directory" ) ? true : false
}

function prepare_selected_item_data(        _selected, _selected_keypath ){
    _selected = data[ cur_keypath L ctrl_win_val(treectrl, cur_keypath) ]
    _selected_keypath = cur_keypath S _selected
    # if ( is_expandable( _selected_keypath ) == false ) return
    get_data( _selected_keypath )
}

function get_data( curkp,            cmd_format, _curkp_arrl, _curkp_arr, _line, curkp_to_json, _len, _max_len, i ){
    if (data[ curkp L ] != "")  return
    cmd_format = ". ~/.x-cmd/xrc/latest; xrc env/lib/main ; ___x_cmd_env_candidate_all"
    # cmd_format = "cd ~/.x-cmd/env/lib/app/candidate/sdk; ls; cd - >/dev/null"
    if (curkp != ".") {
        _curkp_arrl  = split( curkp, _curkp_arr, S)
        cmd_format = "cat ~/.x-cmd/.env/info/%s.json  2>/dev/null"

        cmd_format = sprintf(cmd_format, _curkp_arr[2], _curkp_arr[2])
        cmd_format = ". ~/.x-cmd/xrc/latest; xrc env/lib/app/lsenv;" cmd_format "| ___x_cmd_ui_get_env_ls %s"
        curkp_to_json = substr(curkp, index(curkp, _curkp_arr[2]) + length(_curkp_arr[2]))
        gsub(S, ".", curkp_to_json)
        cmd_format = sprintf(cmd_format, curkp_to_json)
    }

    for (i=1; cmd_format | getline _line; i++) {
        data[ curkp L i ] = _line
        data[ curkp S _line A "INFO" ] = "It is " _line " information"

        _len = wcswidth(_line)
        if ( _max_len < _len) _max_len = _len
    }
    data[ curkp A "MAX_LEN" ]    = _max_len
    i-=1
    data[ curkp L ] = i
    if ( MAX_DATA_ROW_NUM < i ) MAX_DATA_ROW_NUM = i
    ctrl_win_init( treectrl, curkp, 1, data[ curkp L ], get_view_body_row_size() )
    return
}

END {
    if ( exit_is_with_cmd() == true ) {
        _selected = data[ cur_keypath L ctrl_win_val( treectrl, cur_keypath ) ]
        split(  cur_keypath, cur_arr, S)
        send_env( "___X_CMD_UI_LSENV_FINAL_COMMAND",    exit_get_cmd() )
        send_env( "___X_CMD_UI_LSENV_CURRENT_CANDIDATE",  cur_arr[2] )
        send_env( "___X_CMD_UI_LSENV_CURRENT_VERSION",  _selected )
    }
}
# EndSection
