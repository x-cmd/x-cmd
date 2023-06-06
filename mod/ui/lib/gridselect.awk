
# Section: help
BEGIN {
    if (SELECT_HELP_STATE == true){
        ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
        ctrl_help_item_put("n/p", "for next/previous page")
        ctrl_help_item_put("ENTER", "for enter")
        ctrl_help_item_put("%", "for filter")
        ctrl_help_item_put("/", "for find")
        ctrl_help_item_put("SPACE", "for multiple select")
    }
}
# EndSection

# Section: view
function view_calcuate_geoinfo( ){
    if ( ctrl_help_toggle_state() == true ) {
        view_body_row_num = max_row_size - 10 -1
    } else {
        view_body_row_num = max_row_size - 9 - 1
    }
}

function view(          errormsg){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false

    view_calcuate_geoinfo()

    errormsg = display_ui_errormsg(model_len, view_body_row_num, max_col_size )
    if (errormsg != "") return send_update( errormsg )

    if (SELECT_HELP_STATE == true) _component_help = view_help()
    _component_header       = view_header()
    _component_body         = view_body()
    _component_statusline   = view_statusline()

    send_update(  _component_help _component_header _component_body _component_statusline )
}
function view_help(){
    return sprintf("%s\n\n", th_help_text( ctrl_help_get() ) )
}
function view_header(){
    return sprintf("%s\n", th(TH_GRIDSELECT_HEADER_NORMAL, data_header) )
}

function view_body(            _col_num, _selected_item_idx, _iter_item_idx, _data_item_idx, _item_index, _item_icon, _select_text, _data, _data_info, _data_idx){
    view_item_len       = model_item_max + 4
    view_item_index_len = length(model_len)
    if ( ITEM_INDEX_STATE == true ) view_item_len = view_item_len + view_item_index_len + 2
    if ( ctrl_sw_get( MULTIPLE_EDIT ) == true ) view_item_len = view_item_len + 2
    view_body_col_num   = int( ( max_col_size - 1) / view_item_len) + 1

    _col_num             = int( ( model_len - 1 ) / view_body_row_num ) + 1
    if ( _col_num <= view_body_col_num ) view_body_row_num = int( (model_len - 1 ) / _col_num ) + 1

    view_page_item_num  = view_body_col_num * view_body_row_num

    view_page_num       = int( ( model_len - 1 ) / view_page_item_num ) + 1
    _selected_item_idx  = ctrl_rstate_get( SELECTED_ITEM_IDX )
    page_index = int( (_selected_item_idx - 1) / view_page_item_num ) + 1
    page_begin = int( (page_index - 1) * view_page_item_num)

    for (i=1; i<=view_body_row_num; i ++ ) {
        if (i > model_len) break
        for (j=0; j<view_body_col_num; j++ ) {
            _iter_item_idx = page_begin + i + ( j * view_body_row_num )
            if (_iter_item_idx > model_len) break
            _data_item_idx = model[ _iter_item_idx ]
            _item_text = str_pad_right( data[ _data_item_idx ], model_item_max, data_wlen[ _data_item_idx ] )

            if ( ITEM_INDEX_STATE == true ) _item_index = str_pad_left( _data_item_idx, view_item_index_len) ": "
            if ( ctrl_sw_get( MULTIPLE_EDIT ) == true ) {
                _item_icon = "● "
                if ( IS_SELECTED_ITEM[ _iter_item_idx ] == true )   _item_icon = th(TH_GRIDSELECT_ITEM_ICON, _item_icon)
                else _item_icon = th(TH_GRIDSELECT_ITEM_UNICON, _item_icon)
            }
            if ( _iter_item_idx == _selected_item_idx )              _data = _data th(TH_GRIDSELECT_ITEM_SELECTED_INFO, "  > ") _item_icon _item_index th(TH_GRIDSELECT_ITEM_FOCUSED, _item_text)
            else _data = _data  "    " _item_icon _item_index th(TH_GRIDSELECT_ITEM_UNFOCUSED, _item_text)
            _iter_item_idx += max_data_row_num
        }
        if (i != model_len) _data = _data "\n"
        else _data = _data "\n"
    }
    _data_idx = model[ _selected_item_idx ]
    _data_info = data_info[ _data_idx ]
    if ( _data_info != "" ) _data = _data "INFO: " th(TH_GRIDSELECT_ITEM_SELECTED_INFO, _data_info) "\n"
    return _data
}

function view_statusline(){
    if (ctrl_sw_get(FILTER_EDIT) == true) return th_statusline_text(sprintf("Filter> %s\n", filter[""] th(TH_CURSOR, " ")))
    if (ctrl_sw_get(FIND_EDIT) == true)   return th_statusline_text(sprintf("Find> %s\n", find[""] th(TH_CURSOR, " ")))
}
# EndSection

# Section: model
function model_generate(    _filter,    i, l){
    _filter = filter[""]
    model_item_max = 0
    model_len = 0
    for (i=1; i<=data_len; ++i) {
        if (( index( data[ i ], _filter ) > 0 ) || ( _filter == "" )){
            model[ ++ model_len ] = i
            l = data_wlen[ i ]
            if (model_item_max < l) model_item_max = l
        }
    }
    ctrl_rstate_init( SELECTED_ITEM_IDX, 1, model_len )
    DATA_HAS_CHANGED = true
}
# EndSection

# Section: ctrl
BEGIN {
    ctrl_sw_init( FILTER_EDIT, false )
    ctrl_sw_init( FIND_EDIT, false )
    if ( SELECT_MULTIPLE_STATE == true ) ctrl_sw_init( MULTIPLE_EDIT, true )
    else ctrl_sw_init( MULTIPLE_EDIT, false )
}

function handle_ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER")  {
        ctrl_sw_toggle( FILTER_EDIT )
        model_generate()
        return
    }
    ctrl_lineedit_handle( filter, "", char_type, char_value )
}

function handle_ctrl_in_find_state(char_type, char_value,      i, _find){
    if (char_value == "ENTER")  {
        ctrl_sw_toggle( FIND_EDIT )
        _find = find[""]
        for (i=1; i<=model_len; ++i) {
            if (data[model[i]] ~ _find) return ctrl_rstate_set(SELECTED_ITEM_IDX, i)
        }
        return
    }
    ctrl_lineedit_handle( find, "", char_type, char_value )
}

function handle_ctrl_to_move_focus(char_type, char_value){
    if ((char_value == "n") && (model_len > view_page_item_num) && (page_index < view_page_num))   return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_page_item_num )
    if ((char_value == "p") && (model_len > view_page_item_num) && (page_index > 1))   return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_page_item_num )

    if (char_value == "UP")                         return ctrl_rstate_dec( SELECTED_ITEM_IDX )
    if (char_value == "DN")                         return ctrl_rstate_inc( SELECTED_ITEM_IDX )

    if (char_value == "LEFT" )                      return ctrl_rstate_add( SELECTED_ITEM_IDX, - view_body_row_num )
    if (char_value == "RIGHT")                      return ctrl_rstate_add( SELECTED_ITEM_IDX, + view_body_row_num )
}

function handle_ctrl_to_select_item(char_value,         item) {
    if (char_value != "ENTER")  return
    if (ctrl_sw_get( MULTIPLE_EDIT ) == false) {
        return exit_with_elegant( char_value )
    } else {
        item = ctrl_rstate_get( SELECTED_ITEM_IDX )
        if ( IS_SELECTED_ITEM[ item ] == true ) return IS_SELECTED_ITEM[ item ] = false
        return IS_SELECTED_ITEM[ item ] = true
    }
}

function handle_ctrl_in_normal_state(char_type, char_value) {
    exit_if_detected( char_value, ",q," )
    if (char_type == "ascii-space") {
        (ctrl_sw_get( MULTIPLE_EDIT ) == false) ? ctrl_sw_toggle( MULTIPLE_EDIT ) : exit_with_elegant( char_value )
        SELECT_MULTIPLE_STATE = true
        return
    }
    if (char_value == "/")                                  return ctrl_sw_toggle( FIND_EDIT )    # find
    if (char_value == "%")                                  return ctrl_sw_toggle( FILTER_EDIT )  # filter

    if (char_value == "h" && SELECT_HELP_STATE == true)     return ctrl_help_toggle()

    handle_ctrl_to_move_focus(char_type, char_value)    # ARROW UP/DOWN/LEFT/ROW/n/p
    handle_ctrl_to_select_item(char_value)              # select item
    ctrl_rstate_handle_char( SELECTED_ITEM_IDX, char_type, char_value )
}

function ctrl(char_type, char_value) {
    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        handle_ctrl_in_filter_state(char_type, char_value)
    } else if (ctrl_sw_get( FIND_EDIT ) == true) {
        handle_ctrl_in_find_state(char_type, char_value)
    } else {
        handle_ctrl_in_normal_state(char_type, char_value)
    }
}

function consume_ctrl(      _cmd) {
    if ( try_update_width_height( $0 ) == true ) view()
    if ($0 ~ /^R:/)  return
    DATA_HAS_CHANGED = true
    _cmd=$0
    gsub(/^C:/, "", _cmd)
    idx = index(_cmd, ":")
    ctrl(substr(_cmd, 1, idx-1), substr(_cmd, idx+1))
    view()
}
# EndSection

# Section: consume data
function consume_info(){
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_CTRL
        if ( SELECT_FOCUS_ITEM_IDX != "" ) ctrl_rstate_set(SELECTED_ITEM_IDX, SELECT_FOCUS_ITEM_IDX)
        view()
        return
    }

    data_info[ ++ data_info_len ] = $0
}

function consume_item(       l ){
    if ( $0 == "" ) return
    if ( $0 == "---" ) {
        DATA_MODE = DATA_MODE_INFO
        model_generate()
        data_info_len = 0
        return
    }
    data[ ++ data_len ] = $0
    data_wlen[ data_len ] = wcswidth( $0 )

    # Show the first screen to improve use experience
    if ( data_len == ((max_row_size - 10) * 2)) {
        model_generate()
        view()
    }
}
# EndSection

# Section: input and end
BEGIN {
    DATA_MODE_ITEM = 1
    DATA_MODE_INFO = 2
    DATA_MODE_CTRL = 3
    DATA_MODE = DATA_MODE_ITEM
}
NR==1 {  update_width_height( $2, $3 );  }
NR==2 {  data_header = str_trim($0) }
NR>2 {
    if (DATA_MODE == DATA_MODE_CTRL) { consume_ctrl() }
    else if (DATA_MODE == DATA_MODE_ITEM) { consume_item() }
    else { consume_info() }
}

END {
    if ( exit_is_with_cmd() == true ) {
        _FINAL_COMMAND = exit_get_cmd()
        send_env( "___X_CMD_UI_GRIDSELECT_FINAL_COMMAND", _FINAL_COMMAND )
        if ( _FINAL_COMMAND != "q" ) {
            if (SELECT_MULTIPLE_STATE == true) {
                for (i=1; i<=data_len; ++ i) {
                    if ( IS_SELECTED_ITEM[i] == true ) {
                        _item_idx = model[i]
                        _tmp_cur_iter_item_idx = ( _tmp_cur_iter_item_idx == "" ) ? _item_idx : _tmp_cur_iter_item_idx "\003" _item_idx
                        _tmp_cur_iter_item = ( _tmp_cur_iter_item == "" ) ? data[ _item_idx ] : _tmp_cur_iter_item "\003" data[ _item_idx ]
                    }
                }
            } else {
                _tmp_cur_iter_item_idx = ctrl_rstate_get( SELECTED_ITEM_IDX )
                _tmp_cur_iter_item_idx = model[ _tmp_cur_iter_item_idx ]
                _tmp_cur_iter_item = data[ _tmp_cur_iter_item_idx ]
            }

            send_env( "___X_CMD_UI_GRIDSELECT_CURRENT_ITEM_INDEX",      _tmp_cur_iter_item_idx )
            send_env( "___X_CMD_UI_GRIDSELECT_CURRENT_ITEM",             _tmp_cur_iter_item )
        }
    }

}
# EndSection
