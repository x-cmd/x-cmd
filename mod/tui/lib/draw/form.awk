
function draw_form_style_init(){
    IS_TH_CUSTOM = false
    TH_FORM_ENCRYPTED_STYLE    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_ENCRYPTED_STYLE" ]     : "*"
    TH_FORM_PREFIX_SELECTED    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_PREFIX_SELECTED" ]     : TH_THEME_COLOR "> " UI_END
    TH_FORM_PREFIX_UNSELECTED  = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_PREFIX_UNSELECTED" ]   : "  "
    TH_FORM_PREFIX_WIDTH       = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_PREFIX_WIDTH" ]        : int(wcswidth_cache(str_remove_esc(TH_FORM_PREFIX_UNSELECTED)))
    TH_FORM_UNMATCHED          = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_UNMATCHED" ]           : UI_FG_DARKRED
    TH_FORM_INTERVAL_STYLE     = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_INTERVAL_STYLE" ]      : ": "
    TH_FORM_INTERVAL_WIDTH     = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_INTERVAL_WIDTH" ]      : int(wcswidth_cache(str_remove_esc(TH_FORM_INTERVAL_STYLE)))
    TH_FORM_BUTTON_SELECTED    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_BUTTON_SELECTED" ]     : TH_THEME_COLOR UI_TEXT_UNDERLINE
    TH_FORM_BUTTON_UNSELECTED  = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_BUTTON_UNSELECTED" ]   : ""
    TH_FORM_BUTTON_FOCUSED_SELECTED    = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_BUTTON_FOCUSED_SELECTED" ]     : UI_TEXT_REV TH_THEME_COLOR
    TH_FORM_BUTTON_FOCUSED_UNSELECTED  = ( IS_TH_CUSTOM ) ? ENVIRON[ "___X_CMD_TUI_TH_FORM_BUTTON_FOCUSED_UNSELECTED" ]   : UI_TEXT_DIM TH_THEME_COLOR
}

function draw_form(o, kp, x1, x2, y1, y2, opt, \
    _padding, _draw_box, _draw_body, _draw_button, _draw_sel){

    if ( opt_getor( opt, "form.box.enable", false ) ){
        _draw_box = draw_form___on_box(o, kp, x1, x2, y1, y2, opt)
        x1++; x2--; y1++; y2--
    }

    _padding = opt_get( opt, "form.padding" )
    x1+=_padding; x2-=_padding; y1+=_padding; y2-=_padding

    _draw_body    = draw_form___on_body( o, kp, x1, x2-1, y1, y2, opt )
    _draw_sel     = draw_form___on_select( o, kp, x1, x2-1, y1, y2, opt )
    _draw_button  = draw_form___on_button( o, kp, x2, x2, y1, y2, opt )

    return _draw_box _draw_body _draw_button _draw_sel
}

function draw_form___on_box(o, kp, x1, x2, y1, y2, opt,         _color){
    if (!opt_get( opt, "form.box.change" ) ) return
    _color = opt_get( opt, "box.color" )
    if ( opt_getor( opt, "box.arc", false ) ) return painter_box_arc( x1, x2, y1, y2, _color )
    return painter_box( x1, x2, y1, y2, _color )
}

function draw_form___on_body(o, kp, x1, x2, y1, y2, opt, \
    row, col, _width, _desc_width, lw, rw, r, l, i, s, _start, _end){
    if (! opt_get( opt, "form.body.change" )) return
    _next_line = "\r\n" painter_right( y1 )
    row = x2-x1;  col = y2-y1+1

    _width = col - TH_FORM_PREFIX_WIDTH - TH_FORM_INTERVAL_WIDTH
    _desc_width = int( 0.7 * _width )
    lw = opt_getor( opt, "form.desc.width", 10 )
    lw = (lw <= _desc_width) ? lw : _desc_width
    rw = _width - lw
    opt_set( opt, "form.left.with",     lw )
    opt_set( opt, "form.right.with",    rw )

    r = opt_getor( opt, "form.currow", 1 )
    _start = opt_getor( opt, "form.body.start", 1)
    l = r - _start + 1
    if (l > row) _start = r - row + 1
    else if (l <= 0) _start = r

    _end = _start + row - 1
    opt_set( opt, "form.body.start", _start )
    opt_set( opt, "form.body.end",   _end )

    l = opt_getor( opt, "form.len", 1 )
    s = draw_form___on_cell(o, kp, _start, r, lw, rw, opt)
    for (i=_start+1; i<=_end && i<=l; ++i) {
        s = s _next_line draw_form___on_cell(o, kp, i, r, lw, rw, opt)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) s
}

function draw_form___on_cell(o, kp, i, currow, lw, rw, opt,             val, desc, _is_matched, _is_encrypted, _opt){
    val     = form_arr_data_val(o, kp, i)
    desc    = form_arr_data_desc(o, kp, i)

    _is_matched = true
    if (form_arr_data_is_rule(o, kp, i) && (val != "")) _is_matched = form_arr_data_is_match_rule(o, kp, i, val)
    _is_encrypted = form_arr_data_is_encrypted(o, kp, i)
    if (_is_encrypted && (val != "")) gsub(".", TH_FORM_ENCRYPTED_STYLE, val)

    desc = draw_unit_truncate_string( desc, lw )
    if (opt_get( opt, "form.is_ctrl_exit_strategy" ) || (i != currow)) {
        val = draw_unit_truncate_string( val, rw )
        if (!_is_matched) val = th( TH_FORM_UNMATCHED, val)
        return TH_FORM_PREFIX_UNSELECTED desc TH_FORM_INTERVAL_STYLE val
    }
    else {
        opt_set( _opt, "line.text",     val )
        opt_set( _opt, "line.width",    rw )
        opt_set( _opt, "advise.text",   opt_get( opt, "form.edit.advise") )
        opt_set( _opt, "cursor.pos",    opt_get( opt, "form.edit.cursor" ) )
        opt_set( _opt, "start.pos",     opt_get( opt, "form.edit.start" ) )
        opt_set( _opt, "display.error", (!_is_matched) )
        val = draw_lineeditadvise_str_with_cursor_advise(_opt)
        return TH_FORM_PREFIX_SELECTED desc TH_FORM_INTERVAL_STYLE val
    }
}

function draw_form___on_select(o, kp, x1, x2, y1, y2, opt, \
    lw, r, _start, _end, _len, l, row, i, gkp, _color, _draw_sel_box, _draw_sel_body){
    if (! opt_get( opt, "form.sel.change" )) return
    if (! opt_get( opt, "form.is_ctrl_form_sel" )) return
    lw = opt_get( opt, "form.left.with" )
    y1 = y1 + lw + TH_FORM_PREFIX_WIDTH + TH_FORM_INTERVAL_WIDTH
    r  = opt_getor( opt, "form.currow", 1 )
    _start = opt_get( opt, "form.body.start" )
    _end   = opt_get( opt, "form.body.end" )
    i = r - _start + 1
    l = (_len = form_arr_data_select_len(o, kp, r)) + 2
    if (l > 5) l = 5

    row = x2 - x1 + 1
    gkp = kp SUBSEP r SUBSEP "comp.gsel"
    comp_gsel_model_end(o, gkp)
    if ((row - i) >= l){
        x1 = x1 + i
        x2 = x1 + l - 1
    } else if ((i - l) > 0){
        x2 = x1 + i - 2
        x1 = x2 - l + 1
    } else if (row < l){
        opt_set( opt, "form.sel.unable", true )
        return
    }
    _color = opt_get( opt, "box.color" )
    _draw_sel_box = painter_box( x1, x2, y1, y2, _color )
    x1++; x2--; y1++; y2--
    _draw_sel_body = comp_gsel_paint(o, gkp, x1, x2, y1, y2, true, true)

    return _draw_sel_box _draw_sel_body
}

function draw_form___on_button( o, kp, x1, x2, y1, y2, opt, \
    ci, i, l, v, s, _selected, _unselected ){
    if (! opt_get( opt, "form.button.change" )) return
    ci = opt_get( opt, "form.button.cur-id" )
    l  = form_arr_exit_strategy_len(o, kp)

    if (!opt_get( opt, "form.is_ctrl_exit_strategy" )) {
        _selected   = TH_FORM_BUTTON_SELECTED
        _unselected = TH_FORM_BUTTON_UNSELECTED
    } else {
        _selected   = TH_FORM_BUTTON_FOCUSED_SELECTED
        _unselected = TH_FORM_BUTTON_FOCUSED_UNSELECTED
    }
    for (i=1; i<=l; ++i){
        v = form_arr_exit_strategy_get(o, kp, i)
        s = s "   " ((i!=ci) ? th(_unselected, v) : th(_selected, v))
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) s
}

