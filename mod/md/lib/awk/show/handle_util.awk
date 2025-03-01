# Support java, javascript, bash, awk, ... languages

BEGIN{
    L = "\001"

    HD_STYLE_END       = "\033[0m"

    if ( ( sytle_color == "256" ) || (sytle_color == "true") ) {
        HD_STYLE_HEADER1   = "\033[45;1m"
        HD_STYLE_HEADER2   = "\033[36;1m"
        HD_STYLE_CODE      = "\033[48;5;237;33m"
        HD_STYLE_STRONG    = "\033[36;1m"
        HD_STYLE_ITALIC1   = "\033[38;5;214m"
        HD_STYLE_ITALIC2   = "\033[38;5;141m"
        HD_STYLE_LINK      = "\033[32;4;1m"
        HD_STYLE_IMAGE     = "\033[38;5;118m"
        HD_STYLE_DELETE    = "\033[38;5;244;9m"
    } else {
        HD_STYLE_HEADER1   = "\033[45;1m"
        HD_STYLE_HEADER2   = "\033[36;1m"
        HD_STYLE_CODE      = "\033[33m"
        HD_STYLE_STRONG    = "\033[36;1m"
        HD_STYLE_ITALIC1   = "\033[36;3m"
        HD_STYLE_ITALIC2   = "\033[36;3;1m"
        HD_STYLE_LINK      = "\033[32;4;1m"
        HD_STYLE_IMAGE     = "\033[32m"
        HD_STYLE_DELETE    = "\033[30m"
    }


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

