function comp_form_init(o, kp, exit_strategy, tf){
    o[ kp, "TYPE" ] = "form"
    ctrl_num_init( o, kp SUBSEP "ctrl.form.row", 1 )
    ctrl_sw_init(o, kp SUBSEP "ctrl.form.sel", false)
    ctrl_sw_init(o, kp SUBSEP "ctrl.exit.strategy", tf)
    ctrl_sw_init(o, kp SUBSEP "has.exit.strategy", false)
    comp_form_exit_strategy_init(o, kp, exit_strategy)
    draw_form_style_init()
}

# Section: ctrl handle
function comp_form_handle(o, kp, char_value, char_name, char_type,          _has_no_handle, r, v){
    if ( o[ kp, "TYPE" ] != "form" ) return false
    if (!comp_form_is_ctrl_exit_strategy(o, kp)) {
        if (comp_form___ctrl_lineeditadvise( o, kp, char_value, char_name, char_type )) {
            r = comp_form_get_cur_row(o, kp)
            if (comp_form_data_is_select(o, kp, r) && ctrl_sw_get(o, kp SUBSEP "ctrl.form.sel")){
                comp_form_data_lineedit_put_sel(o, kp, r)
                change_set( o, kp, "form.sel" )
            }
            change_set( o, kp, "form.body" )
            return true
        }
        else if (ctrl_sw_get(o, kp SUBSEP "ctrl.form.sel")){
            r = comp_form_get_cur_row(o, kp)
            if (char_name == U8WC_NAME_CARRIAGE_RETURN) ctrl_sw_toggle(o, kp SUBSEP "ctrl.form.sel")
            else if (comp_gsel_handle(o, kp SUBSEP r SUBSEP "comp.gsel", char_value, char_name, char_type)) _has_no_handle = false
            else _has_no_handle = true

            if (_has_no_handle == false){
                comp_form_data_sel_put_lineedit(o, kp, r)
                comp_gsel_model_end(o, kp SUBSEP r SUBSEP "comp.gsel")
                change_set( o, kp, "form.sel" )
                change_set( o, kp, "form.body" )
                return true
            }
        }
        else if (char_name == U8WC_NAME_UP){
            ctrl_num_rdec(o, kp SUBSEP "ctrl.form.row")
            r = comp_form_get_cur_row(o, kp)
            if (comp_form_data_is_select(o, kp, r)) {
                ctrl_sw_toggle(o, kp SUBSEP "ctrl.form.sel")
                change_set( o, kp, "form.sel" )
            }
            change_set( o, kp, "form.body" )
            return true
        }
        else if ((char_name == U8WC_NAME_DOWN) \
                || (char_name == U8WC_NAME_CARRIAGE_RETURN)){
            if (comp_form_get_cur_row(o, kp) == comp_form_get_data_len(o, kp)) {
                ctrl_sw_toggle(o, kp SUBSEP "ctrl.exit.strategy")
                change_set( o, kp, "form.button" )
            }
            else {
                ctrl_num_inc(o, kp SUBSEP "ctrl.form.row")
                r = comp_form_get_cur_row(o, kp)
                if (comp_form_data_is_select(o, kp, r)) {
                    ctrl_sw_toggle(o, kp SUBSEP "ctrl.form.sel")
                    change_set( o, kp, "form.sel" )
                }
            }
            change_set( o, kp, "form.body" )
            return true
        }
    }
    else if (comp_form___ctrl_exit_strategy(o, kp, char_value, char_name, char_type)) {
        change_set( o, kp, "form.button" )
        return true
    }
    else return false
}

function comp_form___ctrl_exit_strategy(o, kp, char_value, char_name, char_type){
    if ((char_name == U8WC_NAME_UP) || (char_name == U8WC_NAME_DOWN))   {
        ctrl_sw_toggle(o, kp SUBSEP "ctrl.exit.strategy")
        change_set( o, kp, "form.body" )
    }
    else if (char_name == U8WC_NAME_LEFT)                               ctrl_num_rdec(o, kp SUBSEP "ctrl.exit.strategy")
    else if (char_name == U8WC_NAME_RIGHT)                              ctrl_num_rinc(o, kp SUBSEP "ctrl.exit.strategy")
    else if (char_name == U8WC_NAME_CARRIAGE_RETURN)                    ctrl_sw_toggle(o, kp SUBSEP "has.exit.strategy")
    else return false
    return true
}

function comp_form___ctrl_lineeditadvise(o, kp, char_value, char_name, char_type,        r){
    r = comp_form_get_cur_row(o, kp)
    if (comp_lineeditadvise_handle(o, kp SUBSEP "lineedit" SUBSEP r, char_value, char_name, char_type )){
        comp_form_data_val(o, kp, r, comp_lineeditadvise_get(o, kp SUBSEP "lineedit" SUBSEP r), true)
        return true
    }
    return false
}

# EndSection

# Section: form model data
function comp_form_set_advise_fromarr(o, kp, i, arr, argstr){
    return comp_lineeditadvise_set_advise_fromarr(o, kp SUBSEP "lineedit" SUBSEP i, arr, argstr)
}
function comp_form_set_advise_fromfile(o, kp, i, fp, argstr){
    return comp_lineeditadvise_set_advise_fromfile(o, kp SUBSEP "lineedit" SUBSEP i, fp, argstr)
}

function comp_form_get_cur_row(o, kp){
    return ctrl_num_get(o, kp SUBSEP "ctrl.form.row")
}

function comp_form_data_add(o, kp, var, desc, val,       l){
    l = form_arr_data_add(o, kp, var, desc, val)
    comp_lineeditadvise_init( o, kp SUBSEP "lineedit" SUBSEP l, val )
    ctrl_num_set_max(o, kp SUBSEP "ctrl.form.row", l)
    return l
}

function comp_form_get_data_len(o, kp){                return form_arr_get_data_len(o, kp);                 }
function comp_form_get_data_var(o, kp, i){             return form_arr_get_data_var(o, kp, i);              }
function comp_form_data_desc_width(o, kp, v){          return form_arr_data_desc_width(o, kp, v);           }
function comp_form_data_desc(o, kp, i, v, force_set){  return form_arr_data_desc(o, kp, i, v, force_set);   }
function comp_form_data_val(o, kp, i, v, force_set){   return form_arr_data_val(o, kp, i, v, force_set);    }

function comp_form_data_is_rule(o, kp, i){             return form_arr_data_is_rule(o, kp, i);              }
function comp_form_data_get_rule_len(o, kp, i){        return form_arr_data_rule_len(o, kp, i);             }
function comp_form_data_set_rule_arr(o, kp, i, arr){   form_arr_data_rule_set_arr(o, kp, i, arr);           }
function comp_form_data_sel_rule_add(o, kp, i, v){     form_arr_data_rule_set_add(o, kp, i, v);             }

function comp_form_data_is_select(o, kp, i){           return form_arr_data_is_select(o, kp, i);            }
function comp_form_data_get_select_len(o, kp, i){      return form_arr_data_select_len(o, kp, i);           }
function comp_form_data_set_setect_arr(o, kp, i, arr){ form_arr_data_select_set_arr(o, kp, i, arr);         }
function comp_form_data_sel_setect_add(o, kp, i, v){   form_arr_data_select_set_add(o, kp, i, v);           }

function comp_form_data_lineedit_put_sel(o, kp, r,      v){
    v = comp_lineeditadvise_get(o, kp SUBSEP "lineedit" SUBSEP r)
    comp_gsel___slct_put(o, kp SUBSEP r SUBSEP "comp.gsel", v)
}
function comp_form_data_sel_put_lineedit(o, kp, r,      v){
    v = comp_gsel_get_cur_item(o, kp SUBSEP r SUBSEP "comp.gsel")
    comp_lineeditadvise_put(o, kp SUBSEP "lineedit" SUBSEP r, v)
    form_arr_data_val(o, kp, r, v, true)
}

function comp_form_has_exit_strategy_get(o, kp){        return ctrl_sw_get(o, kp SUBSEP "has.exit.strategy");       }
function comp_form_has_exit_strategy_toggle(o, kp){     return ctrl_sw_toggle(o, kp SUBSEP "has.exit.strategy");    }
function comp_form_is_ctrl_exit_strategy(o, kp){        return ctrl_sw_get(o, kp SUBSEP "ctrl.exit.strategy");      }
function comp_form_get_cur_exit_strategy(o, kp){        return ctrl_num_get(o, kp SUBSEP "ctrl.exit.strategy");     }
function comp_form_exit_strategy_len(o, kp){            return form_arr_exit_strategy_len(o, kp);                   }
function comp_form_exit_strategy_get(o, kp, i){         return form_arr_exit_strategy_get(o, kp, i);                }
function comp_form_exit_strategy_init(o, kp, str,           l, arr){
    if (str == "") str = "execute,exit"
    l = arr_cut(arr, str, ",")
    ctrl_num_init(o, kp SUBSEP "ctrl.exit.strategy", 1, l, 1)
    form_arr_exit_strategy_set(o, kp, arr)
}

# EndSection

# Section: paint
function comp_form_model_end(o, kp,         r, i, l){
    comp_form_change_set_all(o, kp)
    r = comp_form_get_cur_row(o, kp)
    l = comp_form_get_data_len(o, kp)
    for (i=1; i<=l; ++i){
        if (comp_form_data_is_select(o, kp, i)) {
            comp_gsel_init(o, kp SUBSEP i SUBSEP "comp.gsel")
            if (i == r) ctrl_sw_toggle(o, kp SUBSEP "ctrl.form.sel")
        }
    }
}

function comp_form_change_set_all(o, kp){
    change_set( o, kp, "form.box" )
    change_set( o, kp, "form.body" )
    change_set( o, kp, "form.sel" )
    change_set( o, kp, "form.button" )
}

function comp_form_paint(o, kp, x1, x2, y1, y2, has_box, color, is_box_arc, padding, \
    _desc_w, _edit_w, _res, r, lw, rw, opt){
    opt_set( opt, "form.padding", padding )
    opt_set( opt, "form.box.enable", has_box )
    opt_set( opt, "form.is_ctrl_exit_strategy", comp_form_is_ctrl_exit_strategy(o, kp))
    opt_set( opt, "form.is_ctrl_form_sel", ctrl_sw_get(o, kp SUBSEP "ctrl.form.sel") )
    if ( change_is(o, kp, "form.box")) {
        change_unset(o, kp, "form.box")
        opt_set( opt, "form.box.change",    true )
        opt_set( opt, "box.color",          color )
        opt_set( opt, "box.arc",            is_box_arc )
    }
    if ( (_body_change = change_is(o, kp, "form.body")) == true) {
        change_unset(o, kp, "form.body")
        opt_set( opt, "form.body.change",   true )
        opt_set( opt, "form.desc.width",    (_desc_w = comp_form_data_desc_width(o, kp)))
        opt_set( opt, "form.currow",        (r = comp_form_get_cur_row(o, kp)))
        opt_set( opt, "form.len",           comp_form_get_data_len(o, kp))
        opt_set( opt, "form.edit.advise",   comp_lineeditadvise___get_adv(o, kp SUBSEP "lineedit" SUBSEP r))
        opt_set( opt, "form.edit.cursor",   comp_lineeditadvise___cursor_pos(o, kp SUBSEP "lineedit" SUBSEP r))
        opt_set( opt, "form.edit.start",    comp_lineeditadvise___start_pos(o, kp SUBSEP "lineedit" SUBSEP r))
        opt_set( opt, "form.body.start",    comp_form___draw_body_start(o, kp))
        if ( change_is(o, kp, "form.sel") ) {
            change_unset(o, kp, "form.sel")
            opt_set( opt, "form.sel.change", true )
        }
    }
    if ( change_is(o, kp, "form.button") ) {
        change_unset(o, kp, "form.button")
        opt_set( opt, "form.button.change", true )
        opt_set( opt, "form.button.cur-id", comp_form_get_cur_exit_strategy(o, kp) )
    }


    _res = draw_form(o, kp, x1, x2, y1, y2, opt)
    if (_body_change) {
        lw = opt_get( opt, "form.left.with" )
        rw = opt_get( opt, "form.right.with" )
        _edit_w = comp_lineeditadvise_width(o, kp SUBSEP "lineedit" SUBSEP r)
        if (_desc_w != lw) comp_form_data_desc_width(o, kp)
        if (_edit_w != rw) comp_lineeditadvise_width(o, kp SUBSEP "lineedit" SUBSEP r, rw)
        if (opt_get( opt, "form.sel.unable" )) ctrl_sw_toggle(o, kp SUBSEP "ctrl.form.sel")
        comp_form___draw_body_start(o, kp, opt_getor( opt, "form.body.start", 1))
    }
    return _res
}

function comp_form___draw_body_start(o, kp, v){
    if (v == "")    return model_arr_get(o, kp, "draw.body.start")
    model_arr_set_key_value(o, kp, "draw.body.start", v)
}

# EndSection
