BEGIN{
    COMP_LINEEDITADVISE_ADV_LAST_ARGSTR = SUBSEP "COMP_LINEEDITADVISE_ADV_LAST_ARGSTR_INIT" # init
    COMP_LINEEDITADVISE_ADV_FILE = "adv.file"
    COMP_LINEEDITADVISE_ADV_ARR = "adv.arr"
}


function comp_lineeditadvise_init( o, kp, val, w) {
    return comp_lineedit_init( o, kp, val, w)
}

function comp_lineeditadvise_width(o, kp, w){
    return comp_lineedit_width(o, kp, w)
}

function comp_lineeditadvise_handle( o, kp, char_value, char_name, char_type,       d ) {
    if ( o[ kp, "TYPE" ] != "lineedit" ) return false
    if ( char_type != U8WC_TYPE_SPECIAL ) {
        if ((char_name == U8WC_NAME_DELETE) || (char_name == U8WC_NAME_BACKSPACE))  ctrl_stredit_value_del(o, kp)
        else if (char_name == U8WC_NAME_HORIZONTAL_TAB) ctrl_stredit_value_add(o, kp, comp_lineeditadvise___get_adv(o, kp))
        else if ((char_value != "") && (char_name == "")) ctrl_stredit_value_add(o, kp, char_value)
        else return false
    }
    else if (char_name == U8WC_NAME_LEFT)   ctrl_stredit_cursor_backward(o, kp)
    else if (char_name == U8WC_NAME_RIGHT)  ctrl_stredit_cursor_forward(o, kp)
    else return false
    change_set( o, kp, "lineedit" )
    return true
}

# Section: paint
function comp_lineeditadvise_change_set( o, kp ){
    change_set(o, kp, "lineedit")
}

function comp_lineeditadvise_paint( o, kp, x1, x2, y1, y2 ){
    return comp_lineeditadvise___paint_with_cursor_advise(o, kp, x1, x2, y1, y2)
}

function comp_lineeditadvise___paint_with_cursor_advise(o, kp, x1, x2, y1, y2,       s, i, _obj){
    if ( ! change_is(o, kp, "lineedit") ) return
    change_unset(o, kp, "lineedit")

    opt_set( _opt, "line.text",     (s = comp_lineeditadvise_get(o, kp)) )
    opt_set( _opt, "line.width",    comp_lineeditadvise_width(o, kp) )
    opt_set( _opt, "cursor.pos",    (i = comp_lineeditadvise___cursor_pos(o, kp)) )
    opt_set( _opt, "start.pos",     comp_lineeditadvise___start_pos(o, kp) )
    opt_set( _opt, "advise.text",   comp_lineeditadvise___get_adv(o, kp, substr(s, i+1)) )

    return draw_lineeditadvise_paint( x1, x2, y1, y2, _opt )
}

# EndSection

# Section: advise jso
function comp_lineeditadvise_set_advise_fromarr(o, kp, arr, argstr){
    change_set( o, kp, "lineedit" )
    o[ kp, "advise", "has.adv" ]         = true
    o[ kp, "advise", "adv.type" ]        = COMP_LINEEDITADVISE_ADV_ARR
    o[ kp, "advise", "adv.argstr" ]      = argstr
    o[ kp, "advise", "adv.last.argstr" ] = COMP_LINEEDITADVISE_ADV_LAST_ARGSTR
    o[ kp, "advise", "data" L ] = l = arr[ L ]
    for (i=1; i<=l; ++i) o[ kp, "advise", "data", i ] = arr[ i ]
}

function comp_lineeditadvise_set_advise_fromfile(o, kp, fp, argstr){
    change_set( o, kp, "lineedit" )
    o[ kp, "advise", "has.adv" ]         = true
    o[ kp, "advise", "adv.type" ]        = COMP_LINEEDITADVISE_ADV_FILE
    o[ kp, "advise", "adv.filepath" ]    = fp
    o[ kp, "advise", "adv.argstr" ]      = argstr
    o[ kp, "advise", "adv.last.argstr" ] = COMP_LINEEDITADVISE_ADV_LAST_ARGSTR
}

function comp_lineeditadvise___has_advise(o, kp){
    return o[ kp, "advise", "has.adv" ]
}

function comp_lineeditadvise___get_adv(o, kp, rv,           adv, _completed_val){
    if (! comp_lineeditadvise___load_advise(o, kp, rv)) return
    if (o[ kp, "advise", "candidate.data" L ] > 0) adv = o[ kp, "advise", "candidate.data", 1 ]
    _completed_val = o[ kp, "advise", "candidate.data", "completed.val" ]
    return substr(adv, length(_completed_val)+1)
}

function comp_lineeditadvise___load_advise(o, kp, rv,       s, i){
    if (rv == ""){
        s = comp_lineeditadvise_get(o, kp)
        i = comp_lineeditadvise___cursor_pos(o, kp)
        rv = substr(s, i+1)
    }
    if ((rv == "") || (rv ~ "^ ")){
        if ( ! comp_lineeditadvise___has_advise(o, kp) ) return
        comp_lineeditadvise___get_advise(o, kp)
        return true
    }
}

function comp_lineeditadvise___get_advise(o, kp,   s, i, fp, obj, _content, _, genv_table, lenv_table, OFFSET){
    s = comp_lineeditadvise_get(o, kp)
    i = comp_lineeditadvise___cursor_pos(o, kp)
    kp = kp SUBSEP "advise"
    argstr = o[ kp, "adv.argstr" ] substr(s, 1, i)
    gsub("\\\\", "&\\", argstr)
    if (o[ kp, "adv.last.argstr" ] == argstr) return
    o[ kp, "adv.last.argstr" ] = argstr
    if (o[ kp, "adv.type" ] == COMP_LINEEDITADVISE_ADV_FILE) {
        comp_lineeditadvise___get_advise_fromfile(o, kp, argstr)
    } else {
        comp_lineeditadvise___get_advise_fromarr(o, kp, argstr)
    }
}

function comp_lineeditadvise___get_advise_fromarr(o, kp, argstr,            _, l, i, v, _l){
    o[ kp, "candidate.data" L ] = 0
    l = split(argstr, _, " ")
    o[ kp, "candidate.data", "completed.val" ] = _[ l ]
    l = o[ kp, "data" L ]
    for (i=1; i<=l; ++i) {
        v = o[ kp, "data", i ]
        if ( v !~ "^" argstr ) continue
        o[ kp, "candidate.data" L ] = _l = o[ kp, "candidate.data" L ] + 1
        o[ kp, "candidate.data", _l ] = v
    }
}

function comp_lineeditadvise___get_advise_fromfile(o, kp, argstr,           argarr, l, i, v, d) {
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

# Section: private
function comp_lineeditadvise_get(o, kp){ return comp_lineedit_get(o, kp) }
function comp_lineeditadvise_put(o, kp, val){ comp_lineedit_put(o, kp, val) }
function comp_lineeditadvise_clear(o, kp){ comp_lineedit_clear(o, kp) }
function comp_lineeditadvise___cursor_pos(o, kp){ return comp_lineedit___cursor_pos(o, kp) }
function comp_lineeditadvise___start_pos(o, kp){ return comp_lineedit___start_pos(o, kp) }
function comp_lineeditadvise___get_cursor_left_value(o, kp){ return comp_lineedit___get_cursor_left_value(o, kp) }
function comp_lineeditadvise___get_cursor_right_value(o, kp){ return comp_lineedit___get_cursor_right_value(o, kp) }
# EndSection

