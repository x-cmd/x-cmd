# Section: user model
function user_form_data_parse(o, kp, argstr,        i, j, l, _l, _, argarr, arr, _desc_mw, _desc_w, has_select){
    l = split( argstr, argarr, "\n--\n" )
    for (i=1; i<=l; ++i){
        _l = split( argarr[i], arr, "\n" )
        _desc_w = wcswidth_cache( arr[2] )
        if (_desc_w > _desc_mw) _desc_mw = _desc_w

        comp_form_data_add(o, kp, arr[1], arr[2], arr[3])
        if (_l <= 3) continue
        if (arr[4] ~ "^=~") {
            for (j=5; j<=_l; ++j) comp_form_data_sel_rule_add(o, kp, i, arr[j])
        }
        else if (arr[4] == "=") {
            has_select = true
            delete _
            for (j=5; j<=_l; ++j) arr_push(_, arr[j])
            comp_form_data_set_setect_arr(o, kp, i, _)
            comp_form_set_advise_fromarr(o, kp, i, _)
        }
    }
    comp_form_data_desc_width(o, kp, _desc_mw)
    comp_form_model_end(o, kp)

    if ( l < ( tapp_canvas_rowsize_get() - 4))  ROW_RECALULATE = l + 4 + ((has_select) ? 3 : 0)
    else if ((l+4) < ROWS - 1)                  ROW_RECALULATE = l + 4
    else                                        ROW_RECALULATE = ROWS - 1
    tapp_canvas_has_changed()
}
function tapp_init(){
    ___X_CMD_TUI_FORM_ARGSTR = ENVIRON[ "___X_CMD_TUI_FORM_ARGSTR" ]
    if (___X_CMD_TUI_FORM_ARGSTR == "") panic("The tui form data is empty")
    comp_form_init(o, FORM_KP, "execute,exit")
    user_form_data_parse(o, FORM_KP, ___X_CMD_TUI_FORM_ARGSTR)
}

# EndSection

# Section: user ctrl
function tapp_canvas_rowsize_recalulate( rows ){
    if (rows < 10) return false
    return (ROW_RECALULATE == "") ? 10 : ROW_RECALULATE # rows - 1    # Assure the screen size
}

function tapp_canvas_colsize_recalulate( cols ){
    if (cols < 30) return false
    return cols -2
}

function tapp_handle_clocktick( idx, trigger, row, col ){
    if (ROWS_COLS_HAS_CHANGED) comp_form_change_set_all(o, FORM_KP)
    user_paint( 1, row, 1, col )
}

function tapp_handle_wchar( value, name, type ){
    comp_handle_exit( value, name, type )
    if (comp_form_is_ctrl_exit_strategy(o, FORM_KP)) {
        if (value == "q")                                   exit(0)
    }
    if (comp_form_handle(o, FORM_KP, value, name, type)){
        if (comp_form_has_exit_strategy_get(o, FORM_KP))    exit_with_elegant("ENTER")
        return true
    }
    return false
}

function tapp_handle_response(fp){
}

function tapp_handle_exit( exit_code,       v, e, i, l, _unset ){
    if (exit_is_with_cmd()){
        if (!comp_form_has_exit_strategy_get(o, FORM_KP)) return
        e = comp_form_exit_strategy_get(o, FORM_KP, comp_form_get_cur_exit_strategy(o, FORM_KP))
        if (e != "execute") return
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_FORM_FINAL_COMMAND", e ) )
        _unset = "unset ___X_CMD_TUI_FORM_FINAL_COMMAND ;"
        l = comp_form_get_data_len(o, FORM_KP)
        for (i=1; i<=l; ++i){
            var = comp_form_get_data_var(o, FORM_KP, i)
            val = comp_form_data_val(o, FORM_KP, i)
            tapp_send_finalcmd( sh_varset_val( var, val ) )
            _unset = _unset "\nunset " var " ;"
        }
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_FORM_UNSET", _unset ) )
    }
}

# EndSection

# Section: user view
function user_paint( x1, x2, y1, y2,            _res ){
    # r >= 7
    _res = comp_form_paint(o, FORM_KP, x1, x2, y1, y2, true, TH_THEME_COLOR, true)
    paint_screen( _res )
}

# EndSection

