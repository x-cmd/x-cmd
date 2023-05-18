function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
# Section: init
function user_table_comp_init(){
    TABLE_COL_ID                 = TABLE_ADD( "Id" )
    TABLE_COL_NAME               = TABLE_ADD( "Name" )
    TABLE_COL_PATH               = TABLE_ADD( "Path" )
    TABLE_COL_STATE              = TABLE_ADD( "State" )
}
# EndSection

# Section: user controler -- tapp definition
function tapp_init(){
    user_table_model_init()
    comp_textbox_init( o, "scrollable", "scrollable" )
    comp_textbox_init( o, "workflow.vew", "scrollable" )
    ctrl_sw_init( o, "sw.right" )
    ctrl_sw_init( o, "workflow.vew.textbox" )
}

function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 10) return false
    return rows -1  # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols -2
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    user_view(1, row, 1, col )
    # request data
    table_datamodel_refill(o, TABLE_KP )
    # tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    table_handle_tapp_request(o, TABLE_KP)

}


function tapp_handle_wchar(value, name, type){
    if (ctrl_sw_get(o, "sw.right") && (name == U8WC_NAME_RIGHT ) ) return
    else if ( ! table_handle_wchar( o ,TABLE_KP, value, name, type ) && (name == U8WC_NAME_RIGHT ) ) ctrl_sw_toggle(o, "sw.right")
    else if ( ctrl_sw_get(o, "sw.right") )          table_textbox(value, name, type)
    else if (value == "r")                          user_table_model_init()
    else if (value == "i")                          exit_with_elegant(value)
    else if (value == "d")                          exit_with_elegant(value)
    else if (value == "e")                          exit_with_elegant(value)
    else if (value == "v")                          ctrl_sw_toggle(o, "workflow.vew.textbox")
    else if ( ctrl_sw_get(o, "workflow.vew.textbox") )          table_textbox2(value, name, type)
    # if (name != "")                                  table_change_set_all(o, TABLE_KP)

}
function table_textbox(value, name, type){
    if (name == U8WC_NAME_LEFT ) ctrl_sw_toggle(o, "sw.right")
    comp_textbox_change_set( o, "scrollable" )
    comp_textbox_handle( o,"scrollable", value, name, type )
}
function table_textbox2(value, name, type){
    comp_textbox_change_set( o, "scrollable" )
    comp_textbox_handle( o,"scrollable", value, name, type )
}

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

# Section: data binding: table and parsing data
function user_table_data_set( o, kp, text, data_offset,      obj, i, j, il, jl, _key, _dkp, action_kp ){
    jiparse_after_tokenize(obj, text)
    JITER_CURLEN = 0
    il = obj[ L ]
    for (i=1; i<=il; ++i){
        _key = SUBSEP "\"1\"" SUBSEP "\"workflows\""
        jl = obj[ _key L ]
        for (j=1; j<=jl; ++j){
            _dkp = _key SUBSEP "\""j"\""
            TABLE_CELL_DEF( data_offset, TABLE_COL_ID,                      obj[ _dkp, "\"id\"" ] )
            TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,                 juq( obj[ _dkp, "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_PATH,                 juq( obj[ _dkp, "\"path\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_STATE,                juq( obj[ _dkp, "\"state\"" ] ) )
            ++ data_offset
        }
    }
}
# EndSection

# Section
function user_table_model_init(){
    delete o

    TABLE_KP  = "TABLE_KP"
    table_init(o, TABLE_KP)
    user_table_comp_init()

    TABLE_LAYOUT( TABLE_COL_ID,                 5, 10 )
    TABLE_LAYOUT( TABLE_COL_NAME,               5, 20 )
    TABLE_LAYOUT( TABLE_COL_PATH,               10, 30 )
    TABLE_LAYOUT( TABLE_COL_STATE,              10, 20 )
    TABLE_STATUSLINE_ADD( "r", "Refresh", "Press 'r' to refresh table data" )
    TABLE_STATUSLINE_ADD( "i", "dispatch", "Press 'r' to dispatch workflow" )
    TABLE_STATUSLINE_ADD( "d", "disable", "Press 'd' to disable workflow" )
    TABLE_STATUSLINE_ADD( "e", "enable", "Press 'e' to enable workflow" )

    if( tapp_canvas_colsize_get() < 143){
        TABLE_STATUSLINE_ADD( "v", "view", "Press 'v' to see workflow view"  )
    }

    table_statusline_init(o, TABLE_KP)
}

# Section: user view
function user_view( x1, x2 ,y1, y2,        _res, res){

if (has_change_canvas == true) comp_table_change_set_all( o, kp )
    if( tapp_canvas_colsize_get() > 143){
        user_table_paint(o,TABLE_KP, x1, x2 ,y1, y2, ROWS_COLS_HAS_CHANGED )
        ( ctrl_sw_get(o, "sw.right") == true ) ? box_color = TH_THEME_COLOR :  box_color = ""
        comp_textbox_change_set( o, "scrollable" )
        _res = comp_textbox_paint( o, "scrollable", x1, x2-1, int(y2/2)+1, y2, true, box_color )
        paint_screen( _res )
    }else if(ctrl_sw_get(o, "workflow.vew.textbox")){
        res = painter_clear_screen( x2-1, x2, y1, y2)
        comp_textbox_change_set( o, "scrollable" )
        box_color = TH_THEME_COLOR
        paint_screen( res comp_textbox_paint( o, "scrollable", x1, x2-1, y1, y2, true, box_color, true, 1) )
    }else{
        res = painter_clear_screen( x1, x2-1, y1, y2)
        paint_screen( res )
        table_change_set_all(o, TABLE_KP)
        paint_screen( table_paint(o,TABLE_KP, x1, x2, y1, y2, ROWS_COLS_HAS_CHANGED ) )
    }
}
# EndSection

# Section: respond
function table_handle_tapp_request( o, kp,         _run_id ){
    if (! lock_unlocked( o, kp )) return
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    # TODO:
    _run_id = table_arr_get_data(o, kp, comp_table_get_cur_row(o, kp), 1)
    if (o[ kp, _run_id, "ACTION_WORKFLOW_LS", "HAS_CHANGE" ]) return
    if (_run_id != "") tapp_request("data:request:workflow_view:" _run_id)
}
function tapp_handle_response(fp, content){
    content = cat( fp )
    if( table_handle_response(o, TABLE_KP, content) ) return
    else if ( table_handle_workflow_view_response(o, TABLE_KP, content) )return
    else if ( match( content, "^errexit:")) panic( substr( content, RSTART+RLENGTH) )
}

function table_handle_workflow_view_response(o, kp, content,        _run_id){
    if ( match( content, "^data:Runs_ID:[0-9]+") ) {
        _run_id = substr(content, 14, RLENGTH-13)
        content = substr(content, RLENGTH+1)
        o[ kp, _run_id, "ACTION_WORKFLOW_LS" ] = content
        comp_textbox_put(o, "scrollable", content)
        o[ kp, _run_id, "ACTION_WORKFLOW_LS", "HAS_CHANGE" ] = true
        lock_release( o, kp )
        return true
    }
}

function user_table_paint(o, kp, x1, x2, y1, y2, has_change_canvas,        _res, r ){
    if (has_change_canvas == true) table_change_set_all( o, kp )
    if (! comp_statusline_isfullscreen(o, kp SUBSEP "statusline")){
        _res = \
            comp_table_paint( o, kp, x1, x2-1, y1, int(y2/2)) \
            comp_statusline_paint( o, kp SUBSEP "statusline", x2, x2, y1+1, y2 )
        paint_screen( _res )
    }else{
        comp_statusline_set_fullscreen( o, kp SUBSEP "statusline", x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, kp SUBSEP "statusline") )
    }
}

# EndSection

