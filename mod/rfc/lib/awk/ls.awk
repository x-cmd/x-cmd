BEGIN {
    skip = 1
}

$0 ~ /^0001/ {
    skip = 0
}

function csv_quote(e) {
    gsub("\"", "\"\"", e)
    return "\"" e "\""
}

function csv_quote_ifmust( e ){
    return (e ~ "(\")|[\r\n,]") ? csv_quote( e ) : e
}

function handle( o ){
    printf "%s,%s,%s,%s,", "id" , "title" , "author" , "date"
    printf "%s,%s,%s,", "format" , "status" , "doi"
    printf "%s,%s,%s,%s,%s\n", "obsoletes" , "obsoleted_by" , "updates" , "updated_by" , "also"
    while (1) {
        o[ L ] = l  = o[ L ] + 1
        o[ l ] = id = $1

        if ($0 ~ /Not[ ]Issued/) {
            getline
        } else {
            line = $0
            while (getline) {
                if ($0 == "" ) {
                    break
                }
                line = line " " $0
            }

            gsub(/[ \t\b\v\n]+/, " ", line)
            # gsub(",", " ", line)

            match(line, /^[^ ]+ /)
            o[l, "id"] = substr(line, RSTART, RLENGTH-1)
            line = substr(line, RSTART + RLENGTH)
            match(line, /[^.]+\. /)
            o[l, "title"] = substr(line, RSTART, RLENGTH-1)
            line = substr(line, RSTART + RLENGTH)
            match(line, /([A-Za-z]+ [0-9][0-9][0-9][0-9]\.)/)
            o[ l , "author" ] = substr(line, 1, RSTART - 1)
            o[ l , "date" ] = substr(line, RSTART, RLENGTH)
            line = substr(line, RSTART + RLENGTH)
            printf "%s,%s,%s,%s,", o[l, "id"] , csv_quote_ifmust(o[l, "title"]), csv_quote_ifmust(o[l, "author"]), csv_quote_ifmust(o[l, "date"])


            match(line, /\(Format: [^)]+\)/)
            o[ l , "format" ]  = substr(line, RSTART + 9, RLENGTH - 10)
            match(line, /\(Status: [^)]+\)/)
            o[ l , "status" ]  = substr(line, RSTART + 9, RLENGTH - 10)
            match(line, /\(DOI: [^)]+\)/)
            o[ l , "doi" ]  = substr(line, RSTART + 6, RLENGTH - 7)
            printf "%s,%s,%s,", csv_quote_ifmust(o[l, "format"]), csv_quote_ifmust(o[l, "status"]), csv_quote_ifmust(o[l, "doi"])

            match(line, /\(Obsoletes [^)]+\)/)
            o[ l , "obsoletes" ]  = substr(line, RSTART + 11, RLENGTH - 12)
            match(line, /\(Obsoleted by [^)]+\)/)
            o[ l , "obsoleted_by" ]  = substr(line, RSTART + 14, RLENGTH - 15)
            match(line, /\(Updates [^)]+\)/)
            o[ l , "updates" ]  = substr(line, RSTART + 9, RLENGTH - 10)
            match(line, /\(Updated by [^)]+\)/)
            o[ l , "updated_by" ]  = substr(line, RSTART + 12, RLENGTH - 13)
            match(line, /\(Also [^)]+\)/)
            o[ l , "also" ]  = substr(line, RSTART + 6, RLENGTH - 7)
            printf "%s,%s,%s,%s,%s\n", csv_quote_ifmust(o[l, "obsoletes"]) , csv_quote_ifmust(o[l, "obsoleted_by"]), csv_quote_ifmust(o[l, "updates"]), csv_quote_ifmust(o[l, "updated_by"]), csv_quote_ifmust(o[l, "also"])
        }
        if (! getline) return
    }
}

!skip {
    handle( o )
}

END{

}
