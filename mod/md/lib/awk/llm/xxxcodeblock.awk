function hd_codeblock( arr,     i,  _firstline ){
    _firstline = arr[ arr[ ARR_I ] ] # ```
    larr_advance()
    while (arr[ ARR_I ]<=ARR_L) {
        i = arr[ ARR_I ]
        line = arr[i]
        if (line ~ /^[ ]*```$/) {
            larr_advance()
            break
        }
        larr_advance()
        hd_codeblock_1( line, _firstline )
    }
    printf("\n")

    larr_advance()
}

# public private protected static final synchronized native abstract strictfp transient volatile
# function
# ( ) { } [ ]
# number ...
function hd_codeblock_1( line, _firstline ){
    gsub("[0-9]{2,}", HD_STYLE_NUMBER_0 "&" HD_STYLE_NUMBER_1, line)
    gsub("[\\(\\)\\{\\}]", HD_STYLE_BRACKET_0 "&" HD_STYLE_BRACKET_1, line)
    printf(HD_BLANK"%s \n", line)
    # if (_firstline ~ "^```bash$") {
    # }
}

function hd_codeblock_java(){

}
