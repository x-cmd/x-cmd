function user_request_selected_data(){
    tapp_request("data:request")
}
# Section: user model

function tapp_init(){
    PICK_KP = "pick_kp"
    user_request_selected_data()
    pick_init( o, PICK_KP, true, \
        PICK_SELECT_TITLE, PICK_ROW, PICK_COL, PICK_WIDTH, PICK_LIMIT )
}

# EndSection

# Section: user ctrl

function tapp_canvas_rowsize_recalulate( rows,      r ){
    if (rows < 10) return false # Assure the screen size
    r = 30
    return (rows <= r) ? rows - 3 : r
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols -2
}

function tapp_handle_clocktick( idx, trigger, row, col ){
    if (ROWS_COLS_HAS_CHANGED) pick_change_set_all( o, PICK_KP )
    user_view( 1, row, 1, col )
}

function tapp_handle_wchar( value, name, type ){
    pick_handle( o, PICK_KP, value, name, type )
}

function tapp_handle_response(fp,       _content, arr){
    _content = cat(fp)
    if( _content == "" ) panic("list data is empty")
    arr_cut(arr, _content, "\n")
    pick_data_set( o, PICK_KP, arr )
}

function tapp_handle_exit( exit_code ){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_PICK_SELECTED_ITEM", pick_result( o, PICK_KP ) ) )
    }
}

# EndSection

# Section: user view

function user_view(x1, x2, y1, y2,      _res){
    _res = pick_paint_auto( o, PICK_KP, x1, x2, y1, y2, \
        PICK_ROW, PICK_COL, PICK_WIDTH )

    paint_screen( _res )
}

# EndSection
