function user_request_data( o, kp, rootkp ){
    navi_request_data(o, kp, rootkp)
}

# Section: user model
function tapp_init(){
    JOB_LOG_KP = "job_log_kp"
    comp_navi_current_position_var(o, JOB_LOG_KP, ___X_CMD_TUI_CURRENT_NAVI_POSITION)
    comp_navi_init(o, JOB_LOG_KP)
}

# EndSection

# Section: user ctrl
# use user_paint and user_request_data
function tapp_handle_clocktick( idx, trigger, row, col ){
    navi_handle_clocktick( o, JOB_LOG_KP, idx, trigger, row, col )
}

function tapp_handle_wchar( value, name, type,           kp, d ){
    return navi_handle_wchar( o, JOB_LOG_KP, value, name, type )
}

function tapp_handle_response(fp,       _content, _rootkp, l, arr){
    _content = cat(fp)
    if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else if ( match( _content, "^data:item:" ) ){
        lock_release( o, JOB_LOG_KP )
        l = split(_content, arr, "\n")
        _rootkp = arr[1];   sub( "^data:item:", "", _rootkp )
        user_data_add( o, JOB_LOG_KP, _rootkp, arr, 2, l )
    }
}

function user_data_add( o, kp, rootkp, arr, start, end,         s, str, _process, _date, _random, _, _log, l, _pl, _dl, i, j, k ) {
    if (rootkp == ""){
        for (s=start; s<=end; ++s){
            str = arr[s]
            if (match(str, "\\.[^.]+\\.")){
                _process = substr(str, RSTART+1, RLENGTH-2)
                _date = substr(str, 1, RSTART-1)
                _random = substr(str, RSTART+RLENGTH)
                jdict_put(_, "", _process, true)
                jdict_put(_, _process, _date, true)
                jdict_put(_, _process S _date, _random, true)
            }
        }

        comp_navi_data_init( o, kp )
        if ((l = _[ L ]) == 0) _log = "job log ls is null"

        for (i=1; i<=l; ++i){
            _process = _[ S i ]
            comp_navi_data_add_kv( o, kp, "", _process, "{",  _process)
            _pl = _[ _process L ]
            comp_navi_data_init( o, kp, _process )
            for (j=1; j<=_pl; ++j){
                _date = _[ _process, j ]
                comp_navi_data_add_kv( o, kp, _process, _date, "{", _process S _date, 30)
                _dl = _[ _process, _date L ]
                comp_navi_data_init( o, kp, _process S _date )
                for (k=1; k<=_dl; ++k){
                    _random = _[ _process, _date, k ]
                    comp_navi_data_add_kv( o, kp, _process S _date, _random, "{", _date "." _process "." _random )
                }
                comp_navi_data_end( o, kp, _process S _date )
            }
            comp_navi_data_end( o, kp, _process )
        }
        comp_navi_data_end( o, kp )
    } else {
        if (start == end)  _log = "job log dir ls is null"
        comp_navi_data_init( o, kp, rootkp )
        for (s=start; s<=end; ++s) comp_navi_data_add_kv( o, kp, rootkp, arr[s], "file", rootkp "/" arr[s] )
        comp_navi_data_end( o, kp, rootkp )
    }
    o[ kp, "LOG_INFO" ] = _log
}

function tapp_handle_exit( exit_code,       arr, logfile, finalcmd, position ){
    if (exit_is_with_cmd()){
        if (comp_navi_get_cur_preview_type(o, JOB_LOG_KP) == "file") {
            finalcmd = FINALCMD
            position = comp_navi_current_position_get(o, JOB_LOG_KP)
            logfile = JOB_LOG_FILE_BASEPATH "/" comp_navi_get_cur_rootkp(o, JOB_LOG_KP)
            tapp_send_finalcmd( sh_varset_val( "logfile", logfile ))
        }
    }
    tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_NAVI_FINAL_COMMAND", finalcmd ) )
    tapp_send_finalcmd( sh_varset_val( "___X_CMD_TUI_CURRENT_NAVI_POSITION", position) )
}

# EndSection

# Section: user view
function user_paint_status( o, kp, x1, x2, y1, y2,      s, l, i, _, _log ) {
    if ( ! change_is(o, kp, "navi.footer") ) return
    change_unset(o, kp, "navi.footer")
    s = comp_navi_get_cur_rootkp(o, kp)
    _log = o[ kp, "LOG_INFO" ]

    gsub( S, " ", s )
    s = th( TH_THEME_MINOR_COLOR, "JOB_LOG: " ) s
    if (_log != "") s = s "\n" th( UI_FG_YELLOW, "Log: " ) _log

    comp_textbox_put( o, kp SUBSEP "navi.footer" , s )
    return comp_textbox_paint( o, kp SUBSEP "navi.footer", x1, x2, y1, y2)
}

function user_paint_custom_component( o, kp, rootkp, x1, x2, y1, y2,        s, r, c, arr, _filepath ){
    if ( ! change_is(o, kp, "navi.preview") ) return
    change_unset(o, kp, "navi.preview")

    comp_textbox_clear(o, "CUSTOM_INFO_KP")
    _filepath = filepath_adjustifwin( JOB_LOG_FILE_BASEPATH "/" rootkp )
    while ((c=(getline r <_filepath))==1) {
        if (r !~ "^"___X_CMD_OUTERR_MIX_PACK_PREFIX) r = "[stderr] " r
        else sub("^"___X_CMD_OUTERR_MIX_PACK_PREFIX, "", r)
        s = (s == "") ? r : s "\n" r
    }
    if (c == -1) panic( "Not found such filepath - " _filepath  )
    close( _filepath )

    comp_textbox_put(o, "CUSTOM_INFO_KP", s)
    return comp_textbox_paint(o, "CUSTOM_INFO_KP", x1, x2, y1, y2)
}

# use user_paint_custom_component and user_paint_status
function user_paint( x1, x2, y1, y2 ){
    navi_paint( o, JOB_LOG_KP, x1, x2, y1, y2 )
}

# EndSection
