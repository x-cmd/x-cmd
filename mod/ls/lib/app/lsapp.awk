function user_request_data( o, kp, rootkp,          p ){
    if (! lock_acquire( o, kp ) ) panic("lock bug")
    p = "/" rootkp
    gsub("/+", "/", p)
    tapp_request( "data:request:local:" rootkp "\n" p)
}

BEGIN{
    LS_APP_NAVI_POSITION = ENVIRON[ "___X_CMD_TUI_NAVI_POSITION" ]
    LS_APP_NAVI_POSITION_ISFUZZY = ENVIRON[ "___X_CMD_TUI_NAVI_POSITION_ISFUZZY" ]
    LS_APP_BASEDATA = ENVIRON[ "___X_CMD_LS_APP_BASEDATA" ]
}

# Section: user model
function tapp_init(){
    delete o
    LS_KP = "ls_kp"
    navi_init(o, LS_KP)

    navi_statusline_add( o, LS_KP, "o", "Open", "Press 'o' to open the file with GUI application" )
    navi_statusline_add( o, LS_KP, "b", "Browse", "Press 'b' to open the file with browser" )
    navi_statusline_add( o, LS_KP, "H", "Hide", "Press 'H' to toggle ignore entries starting with '.'" )
    navi_statusline_init( o, LS_KP )

    CUSTOM_FILEINFO_KP = LS_KP SUBSEP "fileinfo_kp"
    comp_textbox_init(o, CUSTOM_FILEINFO_KP, "scrollable")

    if (LS_APP_BASEDATA != "") user_parse_basedata( o, LS_KP, LS_APP_BASEDATA )                         # data
    else user_parse_basepath(o, LS_KP, ENVIRON[ "___X_CMD_LS_APP_BASEPATH" ], LS_APP_NAVI_POSITION)      # abspath
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, LS_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type ){
    if (navi_handle_wchar( o, LS_KP, value, name, type )) return
    else if (value == "o")  tapp_request( "x:open:"     comp_navi_get_cur_rootkp(o, LS_KP))
    else if (value == "b")  tapp_request( "x:browse:"   comp_navi_get_cur_rootkp(o, LS_KP))
    else if (value == "H")  {
        STATE_HIDDEN_VISIBLE = 1 - STATE_HIDDEN_VISIBLE
        LS_APP_NAVI_POSITION = comp_navi_current_position_get(o, LS_KP)
        tapp_init()
    }
}

function tapp_handle_response(fp,       _content, _rootkp, _log, l, i, arr, v, v_len, max_w){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^data:item:local:" ) ){
        lock_release( o, LS_KP )
        l = split(_content, arr, "\n")
        _rootkp = arr[1];   gsub( "^data:item:local:", "", _rootkp )
        _log = arr[2];      gsub( "^data:log:", "", _log )
        if ((l == 3) && (_log == "")) _log = "Directory is empty"
        o[ LS_KP, _rootkp, "log" ] = str_trim(_log)
        comp_navi_data_init( o, LS_KP, _rootkp )
        for (i=4; i<=l; ++i) {
            v = arr[i]
            if ((v == "") || (arr[ v, "processed" ])) continue
            arr[ v, "processed" ] = true
            v_len = user_local_data_add( o, LS_KP, _rootkp, v )
            if ( max_w < v_len ) max_w = v_len
        }
        max_w = max_w + 2
        comp_navi_data_view_width( o, LS_KP, _rootkp, max_w )
        comp_navi_data_end( o, LS_KP, _rootkp )
    }
}

BEGIN{
    STATE_HIDDEN_VISIBLE = ENVIRON[ "STATE_HIDDEN_VISIBLE" ]
    if (STATE_HIDDEN_VISIBLE=="")   STATE_HIDDEN_VISIBLE = 0
}

function user_local_data_add( o, kp, rootkp, str,          _, name, l, i, _kp, _update, _regex ){
    l = split(str, _, " ")
    if (l < 7) {
        return
    } else if (_[6] ~ "\\?") {
        _update = _[6]
        _regex = "[\\? ]+"
    } else {
        if (_[1] !~ "^([bc])")  _update = _[6] " " _[7] " " _[8]
        else                    _update = _[7] " " _[8] " " _[9]
        _regex = _update
        gsub(" +", " +", _regex)
        gsub("\\]|\\[|\\)|\\(|\\}|\\{", "\\\\&", _regex)
    }

    if (! match(str, _regex))   return
    name = str_trim(substr(str, RSTART+RLENGTH))
    gsub("^/+", "", name)
    if (STATE_HIDDEN_VISIBLE == 0 && name ~ "^\\.")     return

    _kp = rootkp "/" name
    if (_[1] ~ "^d") comp_navi_data_add_kv( o, kp, rootkp, TH_THEME_COLOR name, "{", _kp )
    else {
        comp_navi_data_add_kv( o, kp, rootkp, name, "preview", _kp )
        jdict_put( o, kp SUBSEP _kp, "Name", name )
        jdict_put( o, kp SUBSEP _kp, "Mode",  _[1] )
        if (_[1] !~ "^([bc])")  jdict_put( o, kp SUBSEP _kp, "Size",         _[5] )
        else                    jdict_put( o, kp SUBSEP _kp, "Device type",  _[5] " " _[6] )
        jdict_put( o, kp SUBSEP _kp, "Owner", _[3] )
        jdict_put( o, kp SUBSEP _kp, "Group", _[4] )
        jdict_put( o, kp SUBSEP _kp, "Update", _update )
    }
    return wcswidth_without_style_cache(name)
}

function user_parse_basepath(o, kp, pwd, position,       i, l, pa, a, v, s, str, col){
    l = split(pwd, a, "/")
    for (i=1; i<=l; ++i){
        v = a[i]
        if( v == "" ) continue
        col ++
        s = s "/" v
        str = ((str != "") ? str POSITION_SEP : "") s
    }
    str = str POSITION_SEP

    if (position != "") {
        l = split(position, pa, POSITION_SEP)
        if (pa[l] ~ "^" pwd) str = position
    }

    if ( ( str ~ "/\\." ) && (STATE_HIDDEN_VISIBLE == 0 ) ) STATE_HIDDEN_VISIBLE = 1
    if (LS_APP_NAVI_POSITION_ISFUZZY != true) draw_navi_initial_col(o, kp, ++col)
    comp_navi_current_position_var(o, kp, str, LS_APP_NAVI_POSITION_ISFUZZY)
}

function user_parse_basedata( o, kp, pathlist,      i, l, _, str, w, max_w, v ){
    l = split( pathlist, _, "\n" )
    for (i=1; i<=l; ++i){
        if ( ! match(_[i], "\001") ) {
            str[ i, "kp" ]   = _[i]
            str[ i, "view" ] = _[i]
        } else {
            v = substr(_[i], RSTART+1)
            str[ i, "kp" ]   = v
            str[ i, "view" ] = th(TH_THEME_MINOR_COLOR, substr(_[i], 1, RSTART-1)) " " v
        }

        w = wcswidth_without_style_cache(str[ i, "view" ] )
        if (max_w < w) max_w = w
    }
    max_w = max_w + 2
    comp_navi_data_init( o, kp )
    for (i=1; i<=l; ++i) comp_navi_data_add_kv( o, kp, "", str[ i, "view" ] , "{", str[ i, "kp" ] , max_w )
    comp_navi_data_end( o, kp )
}

function tapp_handle_exit( exit_code,       p, v ){
    if (exit_is_with_cmd()){
        p = comp_navi_get_cur_rootkp(o, LS_KP)
        gsub("/+", "/", p)
        tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_TUI_NAVI_CUR_FILE", p ) )
        tapp_send_finalcmd( sh_printf_varset_val( "___X_CMD_TUI_NAVI_FINAL_COMMAND", FINALCMD ) )
        v = comp_navi_current_position_get(o, LS_KP)
        tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_NAVI_POSITION", v) )
    }
}

# EndSection

# Section: user view
function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        s, i, l, k ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")

    if ( (l = o[ kp, rootkp L ]) <= 0 ) return
    for (i=1; i<=l; ++i){
        k = o[ kp, rootkp, i ]
        s = ((s != "") ? s "\n" : "" ) th( TH_THEME_MINOR_COLOR, k ": " ) o[ kp, rootkp, k ]
    }
    comp_textbox_put(o, CUSTOM_FILEINFO_KP, s)
    return comp_textbox_paint(o, CUSTOM_FILEINFO_KP, x1, x2, y1, y2)
}

function user_paint_status( o, kp, x1, x2, y1, y2,      s, _log ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    _log = o[ kp, s, "log" ]
    gsub("/+", "/", s)
    s = th( UI_TEXT_BOLD TH_THEME_COLOR, "Path: " ) s
    if ( _log != "" ) s = s "\n" th( UI_FG_YELLOW, "Log: " ) _log

    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2 ){
    navi_paint( o, LS_KP, x1, x2, y1, y2 )
}

# EndSection
