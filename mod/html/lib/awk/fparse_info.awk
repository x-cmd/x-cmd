BEGIN{
    RS = "<"
}

function trim( s ){
    gsub("(^[ \n\r]+)|([ \n\r]+$)", "", s)
    return s
}

{
    if (desc == ""){
        if ($0 ~ /^meta[> ]/) {
            if ($0 ~ /name=.?description.?/) {
                desc = $0
                gsub("^[^>]+>", "", desc)
                desc = trim( desc )
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
        if ($0 ~ /title[^>]*>/) {
            title = $0
            gsub("^title[^>]*>", "", title)
            title = trim( title )
        }
    }
}

END {
    print title
    print desc
}
