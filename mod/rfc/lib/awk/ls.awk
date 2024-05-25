BEGIN {
    skip = 1
}

$0 ~ /^0001/ {
    skip = 0
}

function handle( o ){
    printf "%s,%s,%s,%s,%s,%s,%s\n", "id" , "title" , "author" , "date" , "format" , "status" , "doi"
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
            # 将逗号转为单个空格符
            gsub(",", " ", line)

            match(line, /^[^ ]+ /)
            o[l, "id"] = substr(line, RSTART, RLENGTH-1)
            line = substr(line, RSTART + RLENGTH)

            match(line, /[^.]+\. /)
            o[l, "title"] = substr(line, RSTART, RLENGTH-1)
            line = substr(line, RSTART + RLENGTH)

            # mawk 不支持 [0-9]{4} 这一写法
            match(line, /([A-Za-z]+ [0-9][0-9][0-9][0-9]\.)/)
            o[ l , "author" ] = substr(line, 1, RSTART - 1)
            o[ l , "date" ] = substr(line, RSTART, RLENGTH)
            line = substr(line, RSTART + RLENGTH)

            # 将连续出现的空格符转为单个空格符
            gsub(/[[:space:]]+/, " ", line)

            match(line, /\(Format: [^)]+\)/)
            o[ l , "format" ]  = substr(line, RSTART + 9, RLENGTH - 10)
            match(line, /\(Status: [^)]+\)/)
            o[ l , "status" ]  = substr(line, RSTART + 9, RLENGTH - 10)
            match(line, /\(DOI: [^)]+\)/)
            o[ l , "doi" ]  = substr(line, RSTART + 6, RLENGTH - 7)

            # print "id:", o[l, "id"]
            # print "title:", o[l, "title"]
            # print "author:", o[l, "author"]
            # print "date:", o[l, "date"]
            # print "format:", o[l, "format"]
            # print "status:", o[l, "status"]
            # print "doi:", o[l, "doi"]
            printf "%s,%s,%s,%s,%s,%s,%s\n", o[l, "id"] , o[l, "title"], o[l, "author"], o[l, "date"], o[l, "format"], o[l, "status"], o[l, "doi"]
        }
        if (! getline) return
    }
}

!skip {
    handle( o )
}

END{

}
