BEGIN{
    COMP_LINEEDIT_ADV_LAST_ARGSTR = SUBSEP "COMP_LINEEDIT_ADV_LAST_ARGSTR_INIT" # init
    COMP_LINEEDIT_ADV_FILE = "adv.file"
    COMP_LINEEDIT_ADV_ARR = "adv.arr"

}
function comp_lineedit_init( o, kp, val, w) {
    o[ kp, "TYPE" ] = "lineedit"
    w = (w != "") ? w : 100
    ctrl_stredit_init(o, kp, val, w)
    change_set( o, kp, "lineedit" )
    # comp_lsel_init(o, kp SUBSEP "lsel")
}

function comp_lineedit_width(o, kp, w){
    return ctrl_stredit_width_set(o, kp, w)
}

# TODO: Add Insert.
function comp_lineedit_handle( o, kp, char_value, char_name, char_type,       d ) {
    if ( o[ kp, "TYPE" ] != "lineedit" ) return false
    if ( char_type != U8WC_TYPE_SPECIAL ) {
        if (char_name == U8WC_NAME_DELETE)  ctrl_stredit_value_del(o, kp)
        else if (char_name == U8WC_NAME_HORIZONTAL_TAB) ctrl_stredit_value_add(o, kp, comp_lineedit_get_adv(o, kp))
        else if (char_value != "") ctrl_stredit_value_add(o, kp, char_value)
        else return false
    }
    else if (char_name == U8WC_NAME_LEFT)   ctrl_stredit_cursor_backward(o, kp)
    else if (char_name == U8WC_NAME_RIGHT)  ctrl_stredit_cursor_forward(o, kp)
    else return false
    change_set( o, kp, "lineedit" )
    return true

}

function comp_lineedit_change_set( o, kp ){
    change_set(o, kp, "lineedit")
}

function comp_lineedit_paint( o, kp, x1, x2, y1, y2,       v, p, _res, lv, rv, i, l, adv ){
    if (comp_lineedit_has_advise( o, kp ))
        _res = comp_lineedit_paint_with_cursor_advise(o, kp, x1, x2, y1, y2)
    else
        _res = comp_lineedit_paint_with_cursor(o, kp, x1, y1, y2)

    return _res
}

function comp_lineedit_paint_with_advise_box(o, kp, x1, x2, y1, y2,         rv){
    rv = comp_lineedit_get_cursor_right_value(o, kp)
    comp_lineedit_load_advise(o, kp, rv)
    if (o[ kp, "advise", "candidate.data" L ] <= 0) return
    # comp_lsel_data_clear(o, kp SUBSEP "lsel")
    # comp_lsel_data_cp(o, kp SUBSEP "lsel", o, kp SUBSEP "advise")
    # return comp_lsel_paint_body( o, kp SUBSEP "lsel", x1, x2, y1, y2 )
}

function comp_lineedit_paint_with_cursor(o, kp, x1, y1, y2,       s, i, b, lv, rv, l, _str){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    s = comp_lineedit_get(o, kp)
    i = comp_lineedit_curpos(o, kp)
    b = ctrl_stredit_border_left_get( o, kp )
    lv = substr(s, b+1, i-b)
    rv = substr( wcstruncate_cache(  substr(s, b+1), ctrl_stredit_width_get( o, kp )-1 ), i-b+1 )

    if (rv == "") _str = lv th(TH_CURSOR, " ")
    else {
        l = ctrl_stredit_nextfont_width(rv)
        _str = lv th( TH_CURSOR, substr(rv, 1, l) ) substr(rv, l+1)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}

function comp_lineedit_paint_with_cursor_advise(o, kp, x1, x2, y1, y2,       s, i, b, lv, rv, l, adv, e, _str){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    s = comp_lineedit_get(o, kp)
    i = comp_lineedit_curpos(o, kp)
    b = ctrl_stredit_border_left_get( o, kp )
    lv = substr(s, b+1, i-b)
    rv = substr(s, i+1)
    adv = comp_lineedit_get_adv(o, kp, rv)

    e = substr( wcstruncate_cache( lv adv rv, ctrl_stredit_width_get( o, kp )-1 ), i-b+1 )
    if (e == "") _str = lv th(TH_CURSOR, " ")
    else {
        l = ctrl_stredit_nextfont_width(e)
        rv = substr(e, l+1)
        adv = substr(adv, l+1)
        _str = lv th(TH_CURSOR, substr(e, 1, l)) th(UI_TEXT_DIM, adv) substr(rv, length(adv)+1)
    }
    return painter_clear_screen(x1, x2, y1, y2) painter_goto_rel(x1, y1) _str
}


# Section: private
function comp_lineedit_get( o, kp ) {
    return ctrl_stredit_value(o, kp)
}

function comp_lineedit_curpos(o, kp) {
    return ctrl_stredit_curpos(o, kp)
}

function comp_lineedit_get_cursor_left_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit_curpos(o, kp)
    return substr(v, 1, p-1)
}

function comp_lineedit_get_cursor_right_value(o, kp,        v, p){
    v = comp_lineedit_get(o, kp)
    p = comp_lineedit_curpos(o, kp)
    return substr(v, p)
}

function comp_lineedit_put( o, kp, val ) {
    change_set( o, kp, "lineedit" )
    ctrl_stredit_init(o, kp, val)
}

function comp_lineedit_clear( o, kp ) {
    change_set( o, kp, "lineedit" )
    comp_lineedit_put( o, kp, "" )
}

function comp_lineedit_width_set( o, kp, w ){
    change_set( o, kp, "lineedit" )
    o[ kp, "width" ] = w
}
function comp_lineedit_width_get( o, kp ){ return o[ kp, "width" ];     }

# EndSection

# Section: advise jso
function comp_lineedit_set_advise_fromarr(o, kp, arr, argstr){
    change_set( o, kp, "lineedit" )
    o[ kp, "advise", "has.adv" ]         = true
    o[ kp, "advise", "adv.type" ]        = COMP_LINEEDIT_ADV_ARR
    o[ kp, "advise", "adv.argstr" ]      = argstr
    o[ kp, "advise", "adv.last.argstr" ] = COMP_LINEEDIT_ADV_LAST_ARGSTR
    o[ kp, "advise", "data" L ] = l = arr[ L ]
    for (i=1; i<=l; ++i) o[ kp, "advise", "data", i ] = arr[ i ]
}

function comp_lineedit_set_advise_fromfile(o, kp, fp, argstr){
    change_set( o, kp, "lineedit" )
    o[ kp, "advise", "has.adv" ]         = true
    o[ kp, "advise", "adv.type" ]        = COMP_LINEEDIT_ADV_FILE
    o[ kp, "advise", "adv.filepath" ]    = fp
    o[ kp, "advise", "adv.argstr" ]      = argstr
    o[ kp, "advise", "adv.last.argstr" ] = COMP_LINEEDIT_ADV_LAST_ARGSTR
}

function comp_lineedit_has_advise(o, kp){
    return o[ kp, "advise", "has.adv" ]
}

function comp_lineedit_get_adv(o, kp, rv,           adv, _completed_val){
    comp_lineedit_load_advise(o, kp, rv)
    if (o[ kp, "advise", "candidate.data" L ] > 0) adv = o[ kp, "advise", "candidate.data", 1 ]
    _completed_val = o[ kp, "advise", "candidate.data", "completed.val" ]
    return substr(adv, length(_completed_val)+1)
}

function comp_lineedit_load_advise(o, kp, rv,       s, i){
    if (rv == ""){
        s = comp_lineedit_get(o, kp)
        i = comp_lineedit_curpos(o, kp)
        rv = substr(s, i+1)
    }
    if ((rv == "") || (rv ~ "^ ")){
        if ( ! comp_lineedit_has_advise(o, kp) ) return
        comp_lineedit_get_advise(o, kp)
    }
}

function comp_lineedit_get_advise(o, kp,   s, i, fp, obj, _content, _, genv_table, lenv_table, OFFSET){
    s = comp_lineedit_get(o, kp)
    i = comp_lineedit_curpos(o, kp)
    kp = kp SUBSEP "advise"
    argstr = o[ kp, "adv.argstr" ] substr(s, 1, i)
    gsub("\\\\", "\\\\", argstr)
    if (o[ kp, "adv.last.argstr" ] == argstr) return
    o[ kp, "adv.last.argstr" ] = argstr
    if (o[ kp, "adv.type" ] == COMP_LINEEDIT_ADV_FILE) {
        comp_lineedit_get_advise_fromfile(o, kp, argstr)
    } else {
        comp_lineedit_get_advise_fromarr(o, kp, argstr)
    }
}

function comp_lineedit_get_advise_fromarr(o, kp, argstr,            _, l, i, v, _l){
    o[ kp, "candidate.data" L ] = 0
    l = split(argstr, _, " ")
    o[ kp, "candidate.data", "completed.val" ] = _[ l ]
    l = o[ kp, "data" L ]
    for (i=1; i<=l; ++i) {
        v = o[ kp, "data", i ]
        if ( v !~ "^" argstr ) continue
        o[ kp, "candidate.data" L ] = _l = o[ kp, "candidate.data", L ] + 1
        o[ kp, "candidate.data", _l ] = v
    }
}

function comp_lineedit_get_advise_fromfile(o, kp, argstr,           argarr, l, i, v, d) {
    if ((fp = o[ kp, "adv.filepath" ]) == "") return
    kp = kp SUBSEP "candidate.data"
    if (o[ kp, fp, "has.get.advsie.jso" ] != true) {
        jiparse2leaf_fromfile( o, kp SUBSEP "advise.jso", fp )
        o[ kp, fp, "has.get.advsie.jso" ] = true
    }

    o[ kp L ] = 0
    gsub("[ ]+", "\002", argstr)
    prepare_argarr(argstr, argarr)
    o[ kp, "completed.val" ] = argarr[ argarr[L] ]
    parse_args_to_env( argarr, o, kp SUBSEP "advise.jso" )
    o[ kp L ] = l = CAND[ "CODE" L ]
    for (i=1; i<=l; ++i){
        v = CAND[ "CODE", i ]
        d = CAND[ "CODE", v ]
        o[ kp, i ] = juq(v)
        o[ kp, i, "desc" ] = d
    }
    delete CAND
}
# EndSection
