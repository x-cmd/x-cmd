BEGIN{
    RS = "<"
    if ( ENVIRON[ "NO_COLOR" ] ) {
        STYLE_TITLE = ""
        STYLE_URL   = ""
        STYLE_DESC  = ""
        STYLE_END   = ""
    } else {
        STYLE_TITLE = "\033[96m"
        STYLE_URL   = "\033[90m"
        STYLE_DESC  = "\033[90m"
        STYLE_END   = "\033[0m"
    }
}

function parse_location( data,          l, i, str, arr ){
        l = split( data, arr, "\n" )
        for (i=1; i<=l; ++i){
        str = arr[i]
        if (str ~ "^[l|L]ocation:") {
            location = str
            gsub("^[l|L]ocation[ ]*:[ ]*", "", location)
            location = str_trim( location )
        }
    }
}

function stdout_msg( title, url, desc ){
    print STYLE_TITLE   "- title: " title STYLE_END
    print STYLE_URL     "  url: " url   STYLE_END
    print STYLE_DESC    "  desc: " desc STYLE_END
}

{
    if ($0 ~ "^[l|L]ocation:") {
        parse_location($0)
    }

    if (desc == ""){
        if ($0 ~ /^meta[> ]/) {
            if ($0 ~ /name=.?description.?/) {
                desc = $0
                gsub("^[^>]+>", "", desc)
                desc = str_trim( desc )
                if (desc == "") {
                    desc = $0
                    gsub("^.+[> ]content=", "", desc)

                    gsub(/^"((\\\\)|(\\")|[^"])+"/, "&\n", desc)
                    split( desc, arr, "\n")
                    desc = arr[1]
                }
            }
        }
    }

    if (title == "") {
        if ($0 ~ /(^| )(title|TITLE)[^>]*>/) {
            title = $0
            gsub("^(title|TITLE)[^>]*>", "", title)
            title = str_trim( title )
        }
    }
}

END {
    stdout_msg( str_xml_transpose( title ), str_xml_transpose( location ), str_xml_transpose( desc ) )
}
