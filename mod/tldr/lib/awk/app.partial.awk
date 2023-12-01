function user_tldr_request_data(){
    tapp_request("data:request")
}

function user_request_data( o, kp, rootkp,            list, i, j, k, l, _pages, _cmd, _pl, _sl, _cl, _pv, _sv, _cv, arr, _){
    if ( ( l = TLDR_APP_DATA_ARR[L] ) <= 0 ) return
    for (i=1; i<=l; ++i){
        split(TLDR_APP_DATA_ARR[i], _, "/")
        jdict_put(_pages, "", _[1], true)
        jdict_put(_cmd, _[1] S _[2], _[3], true)
        delete _
    }
    l = _pages[ L ]
    _sl = TLDR_APP_OS_LIST[L]
    comp_navi_data_init( o, kp )
    for (i=1; i<=l; ++i){
        _pv = _pages[ "", i ]
        comp_navi_data_add_kv( o, kp, "", _pv, "{", _pv, 13)
        comp_navi_data_init( o, kp, _pv )
        for (j=1; j<=_sl; ++j){
            _sv = TLDR_APP_OS_LIST[j]
            if ((_cl = _cmd[ _pv, _sv L ]) <= 0) continue
            comp_navi_data_add_kv( o, kp, _pv, _sv, "{", _pv "/" _sv, 10)
            comp_navi_data_init( o, kp, _pv "/" _sv )
            for (k=1; k<=_cl; ++k){
                _cv = _cmd[ _pv, _sv, k ]
                comp_navi_data_add_kv( o, kp, _pv "/" _sv, _cv, "preview", _pv "/" _sv "/" _cv)
            }
            comp_navi_data_end( o, kp, _pv "/" _sv )
        }
        comp_navi_data_end( o, kp, _pv )
    }
    comp_navi_data_end( o, kp )
}

## Section: user model
function tapp_init(){
    user_tldr_init()
    user_tldr_request_data()
}
# EndSection

function tapp_handle_response(fp,       _content){
    _content = cat(fp)
    if( _content == "" )                    panic("list data is empty")
    else if( match( _content, "^errexit:")) panic(substr(_content, RSTART+RLENGTH))
    else arr_cut(TLDR_APP_DATA_ARR, _content, "\n")

    draw_navi_change_set_all( o, TLDR_KP )
}
