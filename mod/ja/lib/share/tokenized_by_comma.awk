BEGIN{
    REGEX_ALL = "\"[^\"\\\\\\001-\\037]*((\\\\[^u\\001-\\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^\"\\\\\\001-\\037]*)*(\"|$)|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|:|null|false|true|[ \\t\\n\\r]+"
    REGEX_HALFSTRING = "^\"[^\"\\\\\\001-\\037]*((\\\\[^u\\001-\\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^\"\\\\\\001-\\037]*)*$" # "
}

function json_to_machine_friendly(text){
    gsub(/"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*("|$)|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", text)
    gsub(/\n[\001-\040]+/, "\n", text)
    # gsub("[\n]+$", "", text)
    return text
}

{
    l = split( json_to_machine_friendly( (LAST == "") ? $0 : (LAST "," $0) ), O, "\n" )
    for (i=1; i<=l-1; ++i) if ( (LAST = O[i]) != "") print LAST

    if ( (LAST = O[l]) !~ /^"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*$/ ) {
        print LAST; LAST = ""
    }
    fflush()
}

END{  if (LAST != "") print LAST; }
