# a.b\\.c.d
# 'a."b.c".d.'"$1"

function selector_normalize_generic( selector, arr,     e, l ){
    if ( selector ~ /^\./ ) selector = "1" selector
    gsub(/\\\\/, "\002", selector)
    gsub(/\\\./, "\003", selector)
    l = split(selector, arr, /\./)
    for (j=1; j<=l; ++j) {
        e = arr[j]
        gsub("\002", "\\\\", e)
        gsub("\003", ".", e)

        # SPECIAL_LINE_BEGIN
        gsub("\\*", "[^" S "]*", e)
        # gsub( /\*\*/, ".*", e)
        # SPECIAL_LINE_END
        arr[j] = jqu( e )    # quote
    }
    return pattern_arr_join( S, l, arr )
}
