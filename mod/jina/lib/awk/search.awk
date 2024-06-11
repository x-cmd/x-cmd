
BEGIN{
    true = 1
    IDX = ENVIRON[ "index" ]
}


function _regex_key( key ){
    return "^\\[[0-9]+\\][ ]" key ":"
}

function _remove_key( line ) {
    gsub("^[^:]+:[ ]", "", line)
    return line
}

function _extract_key( line ) {
    gsub("^\\[[0-9]+\\][ ]", "", line)
    gsub(":[ ].*", "", line)
    return line
}

function printo( o ){
    printf("- %s: |\n    %s\n", "title", o["title"])
    printf("  %s: |\n    %s\n", "url", o["URL Source"])
    if ( "Description" in o ) {
        printf("  %s: |\n    %s\n", "desc", o["Description"])
    } else {
        printf("  desc:\n")
    }

    if ( "Pubslished" in o ) {
        printf("  %s: |\n    %s\n", "published", o["Pubslished"])
    } else {
        printf("  published:\n")
    }

    if ( "markdown" in o ) {
        printf("  %s: |%s\n",  "markdown", o["markdown"])
    } else {
        printf("  markdown:\n")
    }
}

function parse_jina_search(     _title, _url, _markdown_content, _content, o, i, _tmp, _l, j, num ){
    i = 0
    num = 0
    o[ "\001" ] = 1
    if ( IDX != "" )   _l = split( IDX, _tmp, ",")

    getline
    while (true) {
        delete o

        o["title"] = _remove_key( $0 )
        while (getline) {
            if ( $0 ~ _regex_key("Title"))      break
            if ( $0 ~ "^$" )                    continue

            if ( $0 ~ _regex_key("Markdown[ ]Content") ) {
                _content = ""
                while (true) {
                    if (! getline){     o["markdown"] = _content; printo( o );    return; }
                    if ( $0 ~ _regex_key("Title") ) break
                    _content = _content "\n    " $0
                    # Future TODO: add two line speration
                }
                o["markdown"] = _content
                break
            }
            if ($0 ~ _regex_key("[^:]+"))       o[ _extract_key( $0 ) ] = _remove_key( $0 )
        }

        i ++
        if ( IDX != "" ) {
            for (j=1; j<=_l; ++j) {
                if ( _tmp[j] == i ) {
                    num ++
                    printo( o )
                    break
                }
            }
            if ( num == _l ) return
        } else {
            printo( o )
            if ( i == 5 )  return
        }
    }
}

BEGIN{
    parse_jina_search()
}
