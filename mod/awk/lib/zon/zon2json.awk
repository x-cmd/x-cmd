function zon_to_machine_friendly(text){
    gsub(/([.][^ \{\}\[\]]+)|"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|:|,|\]|\.\[|\.\{|\}|null|false|true|[ \t\n\r]+/, "\n&", text)
    # gsub(/^\357\273\277|^\377\376|^\376\377|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub("\n" "[ \t\n\r]+", "\n", text)
    gsub("^[\n]+", "", text)
    return text
}

{
    if ($0 ~ "^[ ]+//.*$") {
        next
    } else {
        str = zon_to_machine_friendly($0)
        l = split(str, arr, "\n")

        for (i=1; i<=l; ++i) {
            line = arr[i]
            # debug( line )
            if (line ~ "^[ ]*$") continue
            if (line == "=") {
                print ":"
            } else if (line ~ "^\\.\\[") {
                print "["
            } else if (line ~ "^\\.\\{") {
                STRUCT_CHAR = 1
                continue
                # print "{"
            } else if (line ~ "^\\]|\\}$") {
                if ( STRUCT_CHAR == 1 ) {
                    STRUCT_CHAR = 0
                    print "{"
                }
                if ( IS_LIST == 1 ) {
                    IS_LIST = 0
                    print "]"
                    continue
                }
                print line
            } else if (line ~ /^\./) {
                if ( STRUCT_CHAR == 1 ) {
                    STRUCT_CHAR = 0
                    print "{"
                }
                print jqu(substr(line, 2))
            } else {
                if ( STRUCT_CHAR == 1 ) {
                    STRUCT_CHAR = 0
                    IS_LIST = 1
                    print "["
                }
                print line
            }
        }
    }
}
