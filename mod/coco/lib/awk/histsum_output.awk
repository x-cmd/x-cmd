BEGIN{
    content_dir = ENVIRON[ "content_dir" ]
    creq_dir = (content_dir "/chat.request")
    cres_dir = (content_dir "/chat.response")

    _text_req = creq_fragfile_unit___get( creq_dir, "content" )
    _text_res = cres_fragfile_unit___get( cres_dir, "content" )
    _l_creq = int( creq_fragfile_unit___get( creq_dir, "usage_input_charlen" ) - length( _text_req ))
    _l_cres = int( length(_text_res) )

    sentat = ENVIRON[ "sentat" ]
    recvat = ENVIRON[ "recvat" ]
    if ( sentat != "" && recvat != "" ) {
        _time_str = date_epochminus(recvat, sentat)
        if ( _time_str != "" ) _detail_str = " · " date_humantime( _time_str )
    }

    if ( _l_creq > _l_cres ) {
        _l_char = (_l_creq - _l_cres)
        _detail_str = sprintf("↓ %0.2f%% · -%d tokens", (_l_char / _l_creq * 100), (_l_char/3)) _detail_str
        _detail_str = " (" _detail_str ")"
    }

    log_info("coco", "History summary generated successfully" _detail_str)
    print _text_res
}