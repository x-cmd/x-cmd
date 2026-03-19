
# Section: Global data
BEGIN {
    KSEP = "\001"

    ctrl_help_item_put("ARROW UP/DOWN/LEFT/ROW", "to move focus")
    ctrl_help_item_put("n/p", "for next/previous page")
    ctrl_help_item_put("c/r/u/d", "for create/retrive/update/delete")
    ctrl_help_item_put("SPACE", "for filter")
}
# EndSection

# Section: view
function view_calcuate_geoinfo(){
    # command line >
    # help: 2/4
    # empty line
    # Filter: 1
    # body:         view_body_row_num
    # SELECT: 1
    # status-line

    # 7, 9
    if ( ctrl_help_toggle_state() == true ) {
        view_body_row_num = max_row_size - 8 - 2
    } else {
        view_body_row_num = max_row_size - 7 - 2
    }
}

function view(              errormsg){
    if (DATA_HAS_CHANGED == false)    return
    DATA_HAS_CHANGED = false
    view_calcuate_geoinfo()

    errormsg = display_ui_errormsg(model_row, view_body_row_num, max_col_size )
    if (errormsg != "") return send_update( errormsg )

    _component_help   = view_help()
    _component_filter = view_filter()
    _component_body   = view_body()


    send_update( _component_help "\n\n" _component_filter  _component_body )
}

function view_help(){
    return th_help_text( ctrl_help_get() )
}
function view_filter(       data){
    if (ctrl_sw_get( FILTER_EDIT ) == true) return th_statusline_text( sprintf("FILTER: %s\n", filter[ ctrl_rstate_get( CURRENT_COLUMN ) ] th(TH_CURSOR, " ")) )
    else return
}

function view_header(       col_i, _col_start, data, _tmp){
    _col_start = view_body_cal_beginning_col()
    data = th( TH_TABLE_HEADER_ITEM_NORMAL, "     ")
    for (col_i=_col_start; col_i<=data_col_num; col_i++) {
        _tmp = sprintf( "  %s ", str_pad_right( data_header_arr[ col_i ], col_max[ col_i ], data_header_arr_wlen[ 1 KSEP col_i ] ) )
        if ( ctrl_rstate_get( CURRENT_COLUMN ) == col_i ) _tmp = th(TH_TABLE_HEADER_ITEM_FOCUSED, _tmp)
        else _tmp = th( TH_TABLE_HEADER_ITEM_NORMAL,  _tmp )
        data = data _tmp
    }

    return data "\n"
}

function view_body_cal_beginning_col(           _col, _col_size, i, _len){
    _col = ctrl_rstate_get( CURRENT_COLUMN )
    _col_size = max_col_size - 5
    for (i=_col; i>=1; --i) {
        _len = col_max[ i ] + 3
        if (_col_size < _len) return i+1
        _col_size -= _len
    }
    return 1
}

function view_body(             model_row_i, col_i, _col_start, model_start_row, _tmp_currow, _data){
    _col_start = view_body_cal_beginning_col()
    _data = view_header()

    _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
    model_start_row = int( (_tmp_currow - 1) / view_body_row_num) * view_body_row_num + 1
    # view_update_table
    for (model_row_i = model_start_row; model_row_i <= model_start_row + view_body_row_num; model_row_i ++) {
        if (model_row_i > model_row) break
        data_row_i = model[ model_row_i ]
        _data = _data sprintf("%s", str_pad_right( data_row_i, 5 ))
        for (col_i=_col_start; col_i<=data_col_num; col_i++) {
            _data = _data update_view_print_cell( model_row_i, data_row_i, col_i )
        }
        _data = _data "\n"
    }
    return _data th_statusline_text( sprintf("SELECT: %s\n", data[ model[_tmp_currow] KSEP ctrl_rstate_get( CURRENT_COLUMN ) ]) )
}

function update_view_print_cell(model_row_i, data_row_i, col_i,       h, _size, _tmp_currow, _data){

    if ( ctrl_rstate_get( CURRENT_COLUMN ) == col_i )           _data = TH_TABLE_SELECTED_COL
    if ( ctrl_rstate_get( CURRENT_ROW ) == model_row_i ) {
        _data = _data TH_TABLE_SELECTED_ROW
        if ( ctrl_rstate_get( CURRENT_COLUMN ) == col_i )  _data = _data TH_TABLE_SELECTED_ROW_COL
    }

    cord = data_row_i KSEP col_i
    _data =_data sprintf( "│ %s ", str_pad_right( data[ cord ], col_max[ col_i ], data_wlen[ cord ] ) )
    return th(TH_TABLE_LINE_ITEM_FOCUSED, _data )
}
# EndSection

# Section: model
function model_generate(  _cord, _elem, row_i, col_i, _ok){
    model_row = 0

    for (col_i = 1; col_i <= data_col_num; col_i ++) {
        if (col_max[ col_i ] < data_header_arr_wlen[ col_i ])   col_max[ col_i ] = data_header_arr_wlen[ col_i ]
    }
    for (row_i = 1; row_i <= data_len; row_i++) {
        _ok = true
        for (col_i = 1; col_i <= data_col_num; col_i++) {
            _filter = filter[ col_i ]
            if (_filter == "") continue
            if (index(data[ row_i KSEP col_i ], _filter) < 1) {
                _ok = false
                break
            }
        }
        if ( _ok == true ) {
            model[ ++ model_row ] = row_i

            for (col_i = 1; col_i <= data_col_num; col_i ++) {
                _cord = row_i KSEP col_i
                if (col_max[ col_i ] < data_wlen[ _cord ])   col_max[ col_i ] = data_wlen[ _cord ]
            }
        }
    }
    ctrl_rstate_init( CURRENT_ROW, 1, model_row )
    DATA_HAS_CHANGED = true
}
# EndSection

# Section: ctrl
BEGIN {     ctrl_sw_init( FILTER_EDIT, false )          }

function ctrl_in_filter_state(char_type, char_value){
    if (char_value == "ENTER") {
        ctrl_sw_toggle( FILTER_EDIT)
        model_generate()
        return
    }
    ctrl_lineedit_handle( filter, ctrl_rstate_get( CURRENT_COLUMN ) , char_type, char_value)
}

function ctrl_in_normal_state(char_type, char_value){
    exit_if_detected( char_value, EXIT_CHAR_LIST )

    if (char_type == "ascii-space")                 return ctrl_sw_toggle( FILTER_EDIT )

    if (char_value == "h")                          return ctrl_help_toggle()

    if (char_value == "n")                          return ctrl_rstate_add( CURRENT_ROW, + view_body_row_num )
    if (char_value == "p")                          return ctrl_rstate_add( CURRENT_ROW, - view_body_row_num )

    if (char_value == "UP")                         return ctrl_rstate_dec( CURRENT_ROW )
    if (char_value == "DN")                         return ctrl_rstate_inc( CURRENT_ROW )

    if (char_value == "LEFT" )                      return ctrl_rstate_dec( CURRENT_COLUMN )
    if (char_value == "RIGHT")                      return ctrl_rstate_inc( CURRENT_COLUMN )
}

function ctrl(char_type, char_value) {
    if (ctrl_sw_get( FILTER_EDIT ) == true) {
        ctrl_in_filter_state(char_type, char_value)
    } else {
        ctrl_in_normal_state(char_type, char_value)
    }
}

# EndSection

# Section: consumer_item and consume_header

BEGIN{
    CONSUMER_ITEM_STREAM = "\001"
    CONSUMER_ITEM_COL = 0
}

function consume_item_push(                 l ){
    CONSUMER_ITEM_COL += 1
    l = wcswidth( CONSUMER_ITEM_STREAM )
    data_line[ data_len ] = ( data_line[ data_len ] == "" ) ? CONSUMER_ITEM_STREAM :data_line[ data_len ] "\003" CONSUMER_ITEM_STREAM

    data[ data_len KSEP CONSUMER_ITEM_COL ] = CONSUMER_ITEM_STREAM
    data_wlen [ data_len KSEP CONSUMER_ITEM_COL ] = l

    if (col_max[ CONSUMER_ITEM_COL ] < l) col_max[ CONSUMER_ITEM_COL ] = l

    CONSUMER_ITEM_STREAM = "\001"
}

function consumer_item() {
    if ($0 == "\003\002\005") {
        ctrl_rstate_init( CURRENT_COLUMN, 1, data_col_num )
        data_len -= 1
        model_generate()
        view()
        DATA_MODE = DATA_MODE_CTRL
        return
    } else if ($0 == "\002") {
        # consume_item_push()

        CONSUMER_ITEM_COL = 0
        data_len += 1
        # Show the first screen to improve use experience
        if ( data_len == max_row_size ) {
            ctrl_rstate_init( CURRENT_COLUMN, 1, data_col_num )
            model_generate()
            view()
        }
    } else if ($0 == "\003") {
        consume_item_push()
    } else {
        CONSUMER_ITEM_STREAM = ( CONSUMER_ITEM_STREAM == "\001" ) ? $0 : CONSUMER_ITEM_STREAM "\n" $0
    }
}

# Using \t to seperate
function consume_header(){
    data_col_num = split($0, data_header_arr, "\t")

    for (i=1; i<=data_col_num; i++) {
        elem = str_trim(data_header_arr[i])
        elem_wlen = wcswidth( elem )

        data_header_arr_wlen [ i ] = elem_wlen
    }
    data_len = 1
}
# EndSection

# Section: MSG Flow And End
NR==1 {     update_width_height( $2, $3 );      }
BEGIN {
    DATA_MODE_ITEM = 1
    DATA_MODE_CTRL = 2
    DATA_MODE = DATA_MODE_ITEM
}

NR==2 {  consume_header(); }

NR>2 {
    if ( DATA_MODE == DATA_MODE_CTRL ) {
        if ( try_update_width_height( $0 ) == true ) view()
        if ($0 ~ /^R:/) next
        DATA_HAS_CHANGED = true
        cmd=$0
        gsub(/^C:/, "", cmd)
        idx = index(cmd, ":")
        ctrl(substr(cmd, 1, idx-1), substr(cmd, idx+1))
        view()
    } else {
        consumer_item()
    }
}

END {
    if ( exit_is_with_cmd() == true ) {
        _FINAL_COMMAND = exit_get_cmd()
        send_env( "___X_CMD_UI_TABLE_FINAL_COMMAND", _FINAL_COMMAND )
        if ( _FINAL_COMMAND != "q" ) {
            if (model_row != 0) {
                _tmp_currow = ctrl_rstate_get( CURRENT_ROW )
                _tmp_curcol = ctrl_rstate_get( CURRENT_COLUMN )
            }
            _tmp_currow = model[ _tmp_currow ]

            send_env( "___X_CMD_UI_TABLE_CURRENT_ROW",      _tmp_currow )
            send_env( "___X_CMD_UI_TABLE_CURRENT_COLUMN",   _tmp_curcol )
            send_env( "___X_CMD_UI_TABLE_CUR_ITEM",         data[ _tmp_currow KSEP _tmp_curcol ] )
            send_env( "___X_CMD_UI_TABLE_CUR_LINE",         data_line[ _tmp_currow ] )
            send_env( "___X_CMD_UI_TABLE_CUR_ROW_HEADER",   data_header_arr[ _tmp_curcol ] )
        }
    }
}
# EndSection
