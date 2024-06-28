function user_request_data( o, kp, rootkp ){
    if ( o[ kp, "data:request" ] ) return
    tapp_request( "data:request" )
    o[ kp, "data:request" ] = 1
}

# Section: parse json
function user_parse_json_data(o, kp, obj,       i, l, _kp, jl, j, v){
    l = obj[L]
    comp_navi_data_init( o, kp )
    if (l == 1){
        _kp = SUBSEP "\"1\""
        l = obj[ _kp L ]
        v = obj[ _kp ]
        if ( v == "{" ) {
            for (i=1; i<=l; ++i) {
                user_parse_json_data_value(o, kp, "", obj, _kp SUBSEP obj[ _kp, i ] )
            }
        }
        else if (v == "[") {
            for (i=1; i<=l; ++i) {
                user_parse_json_data_value(o, kp, "", obj, _kp SUBSEP "\""i"\"", true  )
            }
        }
    }
    else {
        for (i=1; i<=l; ++i){
            _kp = SUBSEP "\"" i "\""
            user_parse_json_data_value(o, kp, "", obj, _kp, true)
        }
    }
    comp_navi_data_end( o, kp )
}

function user_parse_json_data_value(o, kp, rootkp, obj, obj_kp, is_list,            v, name ){
    v = view = obj[ obj_kp ]
    name = obj_kp
    gsub(".*" SUBSEP, "", name)
    if (name ~ "^\"") name = juq(name)
    if (! is_list) {
        if ( v == "{" ) {
            comp_navi_data_add_kv(o, kp, rootkp, TH_THEME_COLOR name, "{", obj_kp )
            user_parse_json_data_dict( o, kp, obj, obj_kp )
            return
        }
        else if ( v == "[" ) {
            comp_navi_data_add_kv(o, kp, rootkp, TH_THEME_MINOR_COLOR name, "{", obj_kp )
            user_parse_json_data_list(o, kp, obj, obj_kp)
            return
        }
        comp_navi_data_add_kv(o, kp, rootkp, name, "preview", obj_kp )
    } else {
        if ( v == "{" ) {
            comp_navi_data_add_kv(o, kp, rootkp, TH_THEME_COLOR "[" name "]{", "{", obj_kp )
            user_parse_json_data_dict( o, kp, obj, obj_kp )
            return
        }
        else if ( v == "[" ) {
            comp_navi_data_add_kv(o, kp, rootkp, TH_THEME_MINOR_COLOR "[" name "][", "{", obj_kp )
            user_parse_json_data_list(o, kp, obj, obj_kp)
            return
        }
        v = (v ~ "^\"") ? juq(v) : v
        comp_navi_data_add_kv(o, kp, rootkp, "[" name "]" v, "preview", obj_kp )
    }
}

function user_parse_json_data_dict(o, kp, obj, obj_kp,          i, l){
    comp_navi_data_init( o, kp, obj_kp )
    l = obj[ obj_kp L ]
    for (i=1; i<=l; ++i) {
        user_parse_json_data_value(o, kp, obj_kp, obj, obj_kp SUBSEP obj[ obj_kp, i ] )
    }
    comp_navi_data_end( o, kp, obj_kp )
}

function user_parse_json_data_list(o, kp, obj, obj_kp,          i, l){
    comp_navi_data_init( o, kp, obj_kp )
    l = obj[ obj_kp L ]
    for (i=1; i<=l; ++i) {
        user_parse_json_data_value(o, kp, obj_kp, obj, obj_kp SUBSEP "\"" i "\"", true )
    }
    comp_navi_data_end( o, kp, obj_kp )
}

function user_parse_action_to_arr(action, arr){
    return arr_cut( arr, action, "\n")
}

function user_parse_action_statusline(o, kp, arr,        i, l){
    l = arr[L]
    for (i=1; i<=l; i+=3) navi_statusline_add(o, kp, arr[i], arr[i+1], arr[i+2])
    navi_statusline_init( o, kp )
}

# EndSection

BEGIN{
    JO_NAV_POSITION = ENVIRON[ "___X_CMD_JO_NAV_JSONL_POSITION" ]
    JO_NAV_JSONL_ACTION = ENVIRON[ "___X_CMD_JO_NAV_JSONL_ACTION" ]
}
# Section: user model
function tapp_init(){
    delete o
    delete OBJ
    JONAV_KP = "JONAV_KP"
    navi_init(o, JONAV_KP)

    if (JO_NAV_JSONL_ACTION != "") {
        user_parse_action_to_arr( JO_NAV_JSONL_ACTION, NAVI_CUSTOM_ACTION )
        user_parse_action_statusline(o, JONAV_KP, NAVI_CUSTOM_ACTION)
    }

    comp_textbox_init(o, CUSTOM_JONAV_KP, "scrollable")
    user_request_data(o, JONAV_KP)
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, JONAV_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type,          i, l, v, p ){
    if (navi_handle_wchar( o, JONAV_KP, value, name, type )) return
    else {
        l = NAVI_CUSTOM_ACTION[L]
        for (i=1; i<=l; ++i){
            v = NAVI_CUSTOM_ACTION[i]
            if ( value != v ) continue
            p = comp_navi_get_cur_rootkp(o, JONAV_KP)
            tapp_request( "x:" v ":" p "\n" jstr1( OBJ, p) )
            return true
        }
        return false
    }
}

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( match( _content, "^errexit:"))              panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^exit:" ) )         exit_with_elegant(substr( _content, RSTART+RLENGTH))
    else if ( match( _content, "^data:json" ) ) {
        if (o[ JONAV_KP, "data:json" ]) return
        o[ JONAV_KP, "data:json" ] = true
        _content = substr( _content, RSTART + RLENGTH )
        jiparse_after_tokenize(OBJ, _content)
        user_parse_json_data( o, JONAV_KP, OBJ )

        if (JO_NAV_POSITION !="") comp_navi_current_position_var(o, JONAV_KP, JO_NAV_POSITION)
    }

}

function tapp_handle_exit( exit_code,       p, v ){
    if (exit_is_with_cmd()){
        p = comp_navi_get_cur_rootkp(o, JONAV_KP)
        tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_JO_NAV_FINAL_COMMAND", FINALCMD ) )
        tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_JO_NAV_KP", p ) )
        v = OBJ[ p ]
        if (( v == "{" ) || ( v == "[" ))   v = jstr1(OBJ, p)
        else if ( v ~ "^\"" )               v = juq(v)
        tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_JO_NAV_VALUE", v ) )

        v = comp_navi_current_position_get(o, JONAV_KP)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_JO_NAV_CURRENT_POSITION", v) )
    }
}


# EndSection

# Section: user view
function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        v ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")
    v = OBJ[ rootkp ]
    if (( v == "{" ) || ( v == "[" ))   v = jstr(OBJ, rootkp)
    else if ( v ~ "^\"" )               v = juq(v)

    comp_textbox_put(o, CUSTOM_JONAV_KP, v)
    return comp_textbox_paint(o, CUSTOM_JONAV_KP, x1, x2, y1, y2)
}

function user_paint_status( o, kp, x1, x2, y1, y2,      s ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    s = th( TH_THEME_COLOR, "KeyPath: " ) s

    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2,            _res ){
    navi_paint( o, JONAV_KP, x1, x2, y1, y2 )
}

# EndSection

