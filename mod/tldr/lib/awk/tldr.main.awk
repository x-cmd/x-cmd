BEGIN{
    if (match(FILEPATH, /:[0-9]+$/)) {
        FILEPATH_LINE = substr( FILEPATH, RSTART + 1 )
        FILEPATH_LINE = int( FILEPATH_LINE + 0 )
        FILEPATH = substr( FILEPATH, 1, RSTART - 1 )
    }

    if (NO_BACKGROUND != 1){
        if ( match(FILEPATH, "pages[^/]+")) {
            _lang = substr(FILEPATH, RSTART+6, RLENGTH-6)
            comp_tldr_parse_ignorelang( TLDR_IGNORELANG_ARR, ENVIRON[ "___X_CMD_TLDR_LANG_IGNORE" ], "," )
            if (TLDR_IGNORELANG_ARR[_lang]) {
                log_debug("tldr", "Special language: " _lang)
                NO_BACKGROUND = 1
            }
        }
    }

    printf( "%s", comp_tldr_paint_of_file_content(cat(FILEPATH), COLUMNS, NO_COLOR, NO_BACKGROUND, DISPLAY_STYLE, FILEPATH_LINE ) )
}
