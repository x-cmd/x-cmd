# Support java, javascript, bash, awk, ... languages

BEGIN{
    L = "\001"

    MD_GETLINE_ARR[ 0 ] = 0
    MD_GETLINE_ARR[ L ] = 0

    MD_OUTPUT_PRINT[ 0 ] = 0
}

function md_getline( input_arr ){
    if (input_arr[ 0 ] == 1) {
        $0 = input_arr[ ++ input_arr[ L ] ]
    } else {
        return getline
    }
}

function md_output( line, arr ){
    if (arr[ 0 ] == 1) {
        arr[ ++arr[ L ] ] = "  " line
    } else {
        print "  " line
    }
}

