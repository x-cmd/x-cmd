function TABLE_ADD( name ){    return table_add(o, TABLE_KP, name);  }
function TABLE_LAYOUT( colid, min, max ){   return table_layout( o, TABLE_KP, colid, min, max );   }
function TABLE_CELL_DEF( rowid, colid, val ){     table_cell_def( o, TABLE_KP, rowid, colid, val ); }
function TABLE_STATUSLINE_ADD( v, s, l ){   table_statusline_add(o, TABLE_KP, v, s, l);}
function user_workflow_view_unava(o, kp, run_id, force_set){
    if ((run_id == "") && (force_set != true))  return o[ kp, "unava.run-id" ]
    o[ kp, "unava.run-id" ] = run_id
}
function user_app_style(o, kp, v){
    # 0 small style; 1 big style
    if (v == "")    return o[ kp, "app.style" ]
    o[ kp, "app.style" ] = v
}
function user_comp_ctrl_sw_toggle(){
    ctrl_sw_toggle( o, APPKP )
    user_change_set_all()
    user_statusline_set()
}
# Section: init
function user_table_comp_init(){
    TABLE_COL_ID                 = TABLE_ADD( "Id" )
    TABLE_COL_NAME               = TABLE_ADD( "Name" )
    TABLE_COL_PATH               = TABLE_ADD( "Path" )
    TABLE_COL_STATE              = TABLE_ADD( "State" )
}
# EndSection

# Section: statusline
function user_statusline_set(){
    if ( ! ctrl_sw_get( o, APPKP ) ) {
        if (comp_table_ctrl_filter_sw_get( o, TABLE_KP)) user_statusline_table_search( o, STATUSLINE_KP )
        else user_statusline_table_normal( o, STATUSLINE_KP )
    }
    else user_statusline_text(o, STATUSLINE_KP)
}
function user_statusline_table_normal(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
    comp_table_inject_statusline_default( o, kp )
    comp_statusline_data_put( o, kp, "/", "Filter",     "Press '/' to filter items" )
    comp_statusline_data_put( o, kp, "q", "Quit",       "Press 'q' to quit table" )
    if (!user_app_style(o, APPKP)) comp_statusline_data_put( o, kp, "v", "Open view", "Press 'v' to see workflow view" )
    comp_statusline_data_put( o, kp, "r", "Refresh",    "Press 'r' to refresh table data" )
    comp_statusline_data_put( o, kp, "i", "Dispatch",   "Press 'i' to dispatch workflow" )
    comp_statusline_data_put( o, kp, "d", "Disable",    "Press 'd' to disable workflow" )
    comp_statusline_data_put( o, kp, "e", "Enable",     "Press 'e' to enable workflow" )
    comp_statusline_data_put( o, kp, "CURRENT INFO" )
}
function user_statusline_table_search(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "enter", "Quit filter" )
}
function user_statusline_text(o, kp){
    comp_statusline_data_clear( o, kp )
    comp_statusline_data_put( o, kp, "?", "Open help", "Close help" )
    comp_statusline_data_put( o, kp, "q", "Quit", "Press 'q' to quit table" )
    if (!user_app_style(o, APPKP)) comp_statusline_data_put( o, kp, "v", "Close view", "Press 'v' to close workflow view" )
    comp_statusline_data_put( o, kp, "↓↑/jk", "Scroll", "Scroll help document" )
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
            TABLE_CELL_DEF( data_offset, TABLE_COL_ID,                   user_table_juq( obj[ _dkp, "\"id\"" ] ))
            TABLE_CELL_DEF( data_offset, TABLE_COL_NAME,                 user_table_juq(obj[ _dkp, "\"name\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_PATH,                 user_table_juq(obj[ _dkp, "\"path\"" ] ) )
            TABLE_CELL_DEF( data_offset, TABLE_COL_STATE,                user_table_juq(obj[ _dkp, "\"state\"" ] ) )
            ++ data_offset
        }
    }
}
# EndSection

# Section: respond
function user_workflow_view_datamode_refill( o, kp,         _run_id ){
    if (! lock_unlocked( o, kp )) return
    if ( (_run_id = user_workflow_view_unava(o, kp)) == "" ) return
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    tapp_request("data:request:workflow_view:" _run_id)
}

function tapp_handle_response(fp, content){
    content = cat( fp )
    if( table_handle_response(o, TABLE_KP, content) ) return
    else if ( user_handle_workflow_view_response(o, VIEW_KP, content) ) return
    else if ( match( content, "^errexit:")) panic( substr( content, RSTART+RLENGTH) )
}

function user_handle_workflow_view_response(o, kp, content,        _run_id){
    if ( match( content, "^data:Runs_ID:[0-9]+") ) {
        _run_id = substr(content, 14, RLENGTH-13)
        content = substr(content, RLENGTH+1)
        o[ kp, "workflow_view_content", _run_id ] = content
        o[ kp, "has.workflow_view_content", _run_id ] = true
        user_workflow_view_unava(o, kp, "", true )
        lock_release( o, kp )
        change_set(o, kp)
        return true
    }
}

# EndSection

# Section user model
function tapp_init(){
    user_table_model_init()
}

function user_table_model_init(){
    delete o

    APPKP   = "APPKP"
    TABLE_KP = APPKP SUBSEP 1
    VIEW_KP  = APPKP SUBSEP 2
    STATUSLINE_KP = APPKP SUBSEP  3

    ctrl_sw_init( o, APPKP )

    table_init(o, TABLE_KP)
    user_table_comp_init()
    TABLE_LAYOUT( TABLE_COL_ID,                 5, 10 )
    TABLE_LAYOUT( TABLE_COL_NAME,               5, 20 )
    TABLE_LAYOUT( TABLE_COL_PATH,               10, 50 )
    TABLE_LAYOUT( TABLE_COL_STATE,              10, 20 )

    comp_textbox_init(o, VIEW_KP, "scrollable")
    comp_statusline_init( o, STATUSLINE_KP, "?" )
    user_statusline_set()
    user_change_set_all()
}

# EndSection

# Section: user controler -- tapp definition
function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 10) return false
    return rows -1  # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols -2
}

function tapp_handle_clocktick( idx, trigger, row, col,        v ){
    # 0 small style; 1 big style
    if( col > 143 ) user_app_style(o, APPKP, 1)
    else user_app_style(o, APPKP, 0)

    if (ROWS_COLS_HAS_CHANGED) user_change_set_all()
    user_paint(1, row, 1, col )
    # request data
    table_datamodel_refill(o, TABLE_KP )
    user_workflow_view_datamode_refill(o, VIEW_KP)

}

function tapp_handle_wchar(value, name, type,       r){
    comp_handle_exit( value, name, type )
    if (comp_statusline_isfullscreen(o, STATUSLINE_KP)){
        if (! comp_statusline_handle( o, STATUSLINE_KP, value, name, type ) ) _has_no_handle = true
        if (! comp_statusline_isfullscreen(o, STATUSLINE_KP)) user_change_set_all()
    }else {
        if (! ctrl_sw_get(o, APPKP)) {
            if (comp_table_handle( o, TABLE_KP, value, name, type ))                comp_table_model_end(o, TABLE_KP)
            else if (name == U8WC_NAME_CARRIAGE_RETURN)                             exit_with_elegant("ENTER")
            else if ((user_app_style(o, APPKP) == 0) && (value == "v"))             user_comp_ctrl_sw_toggle()
            else if ((user_app_style(o, APPKP) == 1) && (name == U8WC_NAME_RIGHT))  user_comp_ctrl_sw_toggle()
            else if (value == "q")                                                  exit(0)
            else if (value == "r")                                                  user_table_model_init()
            else if (value == "i")                                                  exit_with_elegant(value)
            else if (value == "d")                                                  exit_with_elegant(value)
            else if (value == "e")                                                  exit_with_elegant(value)
            else if (value == "/"){
                comp_table_ctrl_filter_sw_toggle( o, TABLE_KP)
                if ( ! comp_table_model_isfulldata(o, TABLE_KP) )                   comp_table_model_fulldata_mode( o, TABLE_KP, FULLDATA_MODE_ONTHEWAY )
            }
            else if (comp_statusline_handle( o, STATUSLINE_KP, value, name, type )) {
                comp_statusline_data_set_long(o, STATUSLINE_KP, "CURRENT INFO", comp_table_get_cur_line(o, TABLE_KP, true, "\n  "))
                return true
            }
            else _has_no_handle = true


            # update statusline
            if (_has_no_handle == false) {
                user_statusline_set()
                user_change_set_all()
            }

        } else {
            if (comp_textbox_handle( o, VIEW_KP, value, name, type ))               change_set(o, VIEW_KP)
            else if (value == "q")                                                  exit(0)
            else if ((user_app_style(o, APPKP) == 0) && (value == "v"))             user_comp_ctrl_sw_toggle()
            else if ((user_app_style(o, APPKP) == 1) && (name == U8WC_NAME_LEFT))   user_comp_ctrl_sw_toggle()
            else if (comp_statusline_handle( o, STATUSLINE_KP, value, name, type )) _has_no_handle = false
            else _has_no_handle = true
        }
    }

}

function tapp_handle_exit( exit_code){
    if (exit_is_with_cmd()){
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_ITEM", table_result_cur_item(o, TABLE_KP) ) )
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_TABLE_CUR_LINE", table_result_cur_line(o, TABLE_KP) ) )
    }
}
# EndSection

# Section: user view
function user_change_set_all(){
    comp_table_change_set_all(o, TABLE_KP)
    change_set(o, VIEW_KP)
    comp_statusline_change_set_all(o, STATUSLINE_KP)
}
function user_workflow_view_paint( x1, x2, y1, y2, is_ctrl ) {
    if ( ! change_is(o, VIEW_KP) ) return
    _run_id = table_arr_get_data(o, TABLE_KP, comp_table_get_cur_row(o, TABLE_KP), 1)
    if (o[ VIEW_KP, "has.workflow_view_content", _run_id ] == false) {
        user_workflow_view_unava(o, VIEW_KP, _run_id)
        content = "Loading workflow view of "_run_id" id ..."
        comp_textbox_clear( o, VIEW_KP )
    } else {
        change_unset(o, VIEW_KP)
        content = o[ VIEW_KP, "workflow_view_content", _run_id ]
        if (o[ VIEW_KP, "last.run-id" ] != _run_id) {
            comp_textbox_clear( o, VIEW_KP )
            o[ VIEW_KP, "last.run-id" ] = _run_id
        }
    }

    comp_textbox_put( o, VIEW_KP, th((is_ctrl ? "" : UI_TEXT_DIM ), content) )
    comp_textbox_change_set(o, VIEW_KP)
    _res = comp_textbox_paint( o, VIEW_KP, x1, x2, y1, y2, true, (is_ctrl ? TH_THEME_COLOR : UI_TEXT_DIM ), true, 1 )
    return _res
}

function user_paint( x1, x2 ,y1, y2,        is_ctrl_text, _res){
    if (! comp_statusline_isfullscreen(o, STATUSLINE_KP)){
        if (ctrl_sw_get(o, APPKP)) is_ctrl_text = true
        if(user_app_style(o, APPKP)){
            _res = \
                comp_table_paint( o, TABLE_KP, x1, x2-1, y1, 70) \
                user_workflow_view_paint( x1, x2-1, 71, y2, is_ctrl_text ) \
                comp_statusline_paint( o, STATUSLINE_KP, x2, x2, y1+1, y2 )
            paint_screen( _res )
        } else {
            if(!is_ctrl_text) _res = comp_table_paint( o, TABLE_KP, x1, x2-1, y1, y2)
            else _res = user_workflow_view_paint( x1, x2-1, y1, y2, is_ctrl_text )
            _res = _res comp_statusline_paint( o, STATUSLINE_KP, x2, x2, y1+1, y2 )
            paint_screen( _res )
        }
    }else{
        comp_statusline_set_fullscreen( o, STATUSLINE_KP, x1, x2, y1, y2 )
        paint_screen( comp_statusline_paint(o, STATUSLINE_KP) )
    }
}


function user_table_juq(str){
    if (str !~ /^".*"$/) return str
    else return juq(str)
}
# EndSection
