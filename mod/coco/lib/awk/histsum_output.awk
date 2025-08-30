{ if ($0 != "") jiparse_after_tokenize(o, $0); }

END{
    CREQ_KP = SUBSEP "\"1\""
    CRES_KP = SUBSEP "\"2\""

    _text_req = juq(o[ CREQ_KP SUBSEP "\"question\"" ])
    _text_res = juq(o[ CRES_KP SUBSEP "\"reply\"" SUBSEP "\"content\"" ])
    _l_creq = int(o[ CREQ_KP SUBSEP "\"usage\"" SUBSEP "\"input\"" SUBSEP "\"stringLength\"" ] - length( _text_req ))
    _l_cres = int( length(_text_res) )
    if ( _l_creq > _l_cres ) {
        _reduction_ratio = sprintf(" (↓ %0.2f%)", (_l_creq - _l_cres) / _l_creq * 100)
    }

    log_info("coco", "History summary generated successfully" _reduction_ratio)
    print _text_res
}