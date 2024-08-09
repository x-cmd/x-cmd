
BEGIN {
    HD_STYLE_CONTENTS_0 = "\033[32m"
    HD_STYLE_CONTENTS_1 = "\033[0m"
    HD_STYLE_NUMBER_0 = "\033[35m"
    HD_STYLE_NUMBER_1 = "\033[0m"
    HD_STYLE_SYMBOL_0 = "\033[36m"
    HD_STYLE_SYMBOL_1 = "\033[0m"

    # ^(M{0,3})(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$
    # ROMAN_NUM = re_interval_expression("M", 1, 3)
    # ROMAN_NUM = ROMAN_NUM "|" "(CM|CD|D?" re_interval_expression("C", 1, 3)      ")"
    # ROMAN_NUM = ROMAN_NUM "|" "(XC|XL|L?" re_interval_expression("X", 1, 3) "|L" ")"
    # ROMAN_NUM = ROMAN_NUM "|" "(IX|IV|V?" re_interval_expression("I", 1, 3) "|V" ")"

    PAT = "(\\*+[^*]+\\*+)" "|" "(\\[+[^]]+\\]+)" "|" "(\\(+[^)]+\\)+)"
    PAT = PAT "|" "([0-9]+)"
    L = "\001"
}

function print_color(str){
    gsub(/[ \r\n]+$/, "", str)
    print HD_STYLE_CONTENTS_0 str HD_STYLE_CONTENTS_1
}

function check_contents_str_trim(str){
    str = tolower( str )
    gsub(/^[ \r\t\b\v\n]+/, "", str)
    gsub(/[ \r\t\b\v\n.]+$/, "", str)
    gsub(/[ \r\t\b\v\n]+/, " ", str)

    gsub("^the ", "", str)
    return str
}

function is_contents(str,           i, l){
    str = check_contents_str_trim(str)
    if ( str == "" ) return 0

    l = contents[ L ]
    for (i=1; i<=l; i++) {
        if ( index( contents[i], str) ) return 1
    }
    return 0
}

function handle_contents(      _space_line ){
    while (getline) {
        if ( $0 ~ /^[ \t\r\n]+$/ )  {
            print $0
            _space_line ++
            continue
        }

        if ((contents[ L ] > 0 ) && ( _space_line >= 3 ))   break
        else if ( $0 ~ "EPILOGUE" )                         break
        else if ((contents[ L ] > 0 ) && \
            ( index(contents[1], check_contents_str_trim( $0 )) )) break

        contents[ ++contents[ L ] ] = check_contents_str_trim($0)
        gsub(/[IVXLCDM]+\./, HD_STYLE_NUMBER_0 "&" HD_STYLE_NUMBER_1, $0)
        print $0
        _space_line = 0
    }
}

{
    if ( tolower($0) ~ "^contents") {
        print_color($0)
        handle_contents()
    }

    if ( is_contents($0) ) {
        print_color($0)
    }else {
        gsub(PAT, HD_STYLE_SYMBOL_0 "&" HD_STYLE_SYMBOL_1, $0)
        print $0
    }
}
