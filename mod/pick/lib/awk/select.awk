function user_request_selected_data(){
    tapp_request("data:request")
}
# Section: user model

function tapp_init(){
    PICK_KP = "pick_kp"
    user_request_selected_data()
    PICK_SIZE[ "ROW" ] = PICK_ROW
    PICK_SIZE[ "COL" ] = PICK_COL
    PICK_SIZE[ "WIDTH" ] = PICK_WIDTH
    PICK_SIZE[ "LIMIT" ] = PICK_LIMIT
    PICK_SIZE[ "TITLE" ] = PICK_SELECT_TITLE
    pick_init( o, PICK_KP, true, PICK_SIZE )
}

# EndSection

# Section: user ctrl

function tapp_canvas_rowsize_recalulate( rows,      r ){
    if (rows < 4) return false # Assure the screen size
    r = 15
    r = (rows <= r) ? rows - 1 : r
    return (ROW_RECALULATE == "") ? r : ROW_RECALULATE
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
    pick_data_set( o, PICK_KP, arr, PICK_SIZE )
}

function tapp_handle_exit( exit_code ){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_PICK_SELECTED_ITEM", pick_result( o, PICK_KP ) ) )
    }
}

# EndSection

# Section: user view

function user_view(x1, x2, y1, y2,      _res){
    _res = pick_paint_auto( o, PICK_KP, x1, x2, y1, y2, PICK_SIZE)
    paint_screen( _res )
}

# EndSection
