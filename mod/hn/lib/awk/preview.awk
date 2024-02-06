
BEGIN{
    NO_COLOR = ENVIRON[ "NO_COLOR" ]
}
{
    _arrl = json_split2tokenarr( _arr, $0 )
    for (i=1; i<=_arrl; ++i) {
        jiparse( o, _arr[i] )
        if (JITER_LEVEL == 0) {
            print hn_preview(o, SUBSEP "\"" JITER_CURLEN "\"", JITER_CURLEN, NO_COLOR)
            fflush()
        }
    }
}
