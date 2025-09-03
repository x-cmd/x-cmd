{ if ($0 != "") jiparse_after_tokenize(o, $0); }

END{
    CREQ_KP = SUBSEP "\"1\""
    CRES_KP = SUBSEP "\"2\""

    _text_req = juq(o[ CREQ_KP SUBSEP "\"question\"" ])
    _text_res = juq(o[ CRES_KP SUBSEP "\"reply\"" SUBSEP "\"content\"" ])
    _l_creq = int(o[ CREQ_KP SUBSEP "\"usage\"" SUBSEP "\"input\"" SUBSEP "\"stringLength\"" ] - length( _text_req ))
    _l_cres = int( length(_text_res) )

    sentat = ENVIRON[ "sentat" ]
    recvat = ENVIRON[ "recvat" ]
    if ( sentat != "" && recvat != "" ) {
        _time_str = date_epochminus(recvat, sentat)
        if ( _time_str != "" ) _detail_str = " · " date_humantime( _time_str )
    }

    if ( _l_creq > _l_cres ) {
        _l_char = (_l_creq - _l_cres)
        _detail_str = sprintf("↓ %0.2f% · -%s tokens", (_l_char / _l_creq * 100), int(_l_char/3)) _detail_str
        _detail_str = " (" _detail_str ")"
    }

    log_info("coco", "History summary generated successfully" _detail_str)
    print _text_res
}