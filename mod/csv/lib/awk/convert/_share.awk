
function all_line_char_is_blank( charpos,   i, line, ch ){
    for (i=1; i<=gli_buffer_len(); ++i) {
        line = gli_buffer_get(i)
        ch = substr(line, charpos, 1)
        if ((ch!=" ") && (ch!="")) {
            # print "0 === " ch "\t" line
            return 0
        }
    }
    return 1
}

function analyse_header( attr, prefetch,    headerline, acc ){
    if (prefetch == "") prefetch = 10
    gli_fetch( prefetch )

    acc = 0
    attr[ attrl = 1 ] = 1
    headerline = $0
    while (match(headerline, "^[^ ]+([^A-Za-z0-9_]+|$)")){
        acc = acc + RLENGTH
        headerline = substr($0, acc+1)
        while ( ! (all_line_char_is_blank( acc )) ) {
            if (! match(headerline, "^[^ ]+[^A-Za-z0-9_]+")) break
            acc = acc + RLENGTH
            headerline = substr($0, acc+1)
        }

        attr[ ++attrl ] = acc + 1
    }
    attr[ L ] = attrl
}
