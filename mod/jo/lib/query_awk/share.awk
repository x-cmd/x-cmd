


function pattern_arr_join( sep, arrl, arr,     i, _ ){
    if (arrl == 0)  return ""
    # "1""LICENSE"
    for (i=1; i<=arrl; ++i) _ = _ sep arr[i]
    return _
}

function pattern_split( selector, arr,     e, l ){
    # print "selector:" selector
    if ( selector ~ /^\.$/) selector = "1"
    if ( selector ~ /^\./ ) selector = "1" selector
    gsub(/\\\\/, "\002", selector)
    gsub(/\\\./, "\003", selector)
    l = split(selector, arr, /\./)
    for (j=1; j<=l; ++j) {
        e = arr[j]
        gsub("\002", "\\\\", e)
        gsub("\003", ".", e)

        arr[j] =  e     # quote
    }

    return l
}

function pattern_quote( arrl, arr,     i, e ){
    for (i=1; i<=arrl; ++i) {
        arr[i] = jqu( arr[i] )
    }
    return arrl
}


function accessor_normalize_arr( selector, arr,     l ){
    l = pattern_split( selector, arr )
    return pattern_quote( l, arr )
}

function accessor_normalize( selector,      arrl, arr){
    arrl = accessor_normalize_arr( selector, arr )
    return pattern_arr_join( S, arrl, arr )
}

# a.b\\.c.d
# 'a."b.c".d.'"$1"

INPUT==0{
    if ($0 == "---") {
        handle_argument( argstr )
        INPUT=1
        next
    }
    argstr = argstr $0
}
