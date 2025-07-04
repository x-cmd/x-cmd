
# https://www.markdownguide.org/basic-syntax/#escaping-characters

function md_handle_code( line, output_arr ){
    md_output( line )
    while (md_getline()) {
        if ( $0 ~ /^```/ ) {
            md_output( $0, output_arr )
            return 1
        }
        # gsub("(^(#|//) .*|^<!-- .+ -->$)", UI_FG_BRIGHT_BLACK "&" UI_END, $0)
        md_output( "  " $0, output_arr )
    }
    return 0
}

function md_handle_note( line, output_arr ){
    if (line ~ "-->$" ) return 1
    while (md_getline()) {
        if ( $0 ~ "-->$" ) return 1
    }
    return 0
}

# the whole line
function md_handle_header( line, output_arr,        ll, rl, header_style, text ){
    if ( line ~ "`[^`]+`" )   line = md_body_transform_quote(line)
    if (!match(line, MD_REGEX_HEADER)) return 0
    ll = substr(line, 1, RLENGTH)
    rl = substr(line, RLENGTH+1)
    gsub("[ ]+", "", ll)

    if ( length(ll) == 1 ) {
        ll = ""
        header_style = HD_STYLE_HEADER1
    } else {
        rl = " " rl
        header_style = HD_STYLE_HEADER2
    }

    gsub("\033\\[0m", "&" header_style, rl )
    text = header_style ll rl HD_STYLE_END

    md_output( text, output_arr )
    return 1
}

function md_str_trim( str ){
    gsub("(^[ ]+)|([ ]+$)", "", str)
    return str
}

BEGIN{
    MD_REGEX_SPACE      = "^[ \t\v\b\r]*$"
    MD_REGEX_HEADER     = "^[ ]*#+[ ]+"
    MD_REGEX_OLIST      = "^[ ]*[0-9]+\\.[ ]+"
    MD_REGEX_BLIST      = "^[ ]*[*+\\-][ ]+"
    MD_REGEX_CODE       = "^[ ]*```[^`]*$"
    MD_REGEX_NOTE       = "^[ ]*<!--"
    MD_REGEX_TABLE      = "[|]"
    MD_REGEX_TABLE_HEADER_LINE = "^[ ]*[ |-]+$"
    # MD_REGEX_TABLE      = "^[ ]*[|].+[|][ ]*$"

}

function md_handle( input_arr, output_arr ){
    while (md_getline( input_arr )) {
        if ($0 ~ /^[ \t\v\b\r]+$/) return 0

        if ( $0 ~ MD_REGEX_CODE ) {
            # debug( "code" )
            if (!md_handle_code( $0, output_arr )) return 0
            continue
        }

        if ( $0 ~ MD_REGEX_HEADER) {
            # debug( "header" )
            if (!md_handle_header( $0, output_arr )) return 0
            continue
        }

        if ($0 ~ MD_REGEX_OLIST) {
            # debug( "olist" )
            if (!md_handle_list( $0, output_arr )) return 0
            continue
        }

        if ($0 ~ MD_REGEX_BLIST) {
            # debug( "blist" )
            if (!md_handle_list( $0, output_arr )) return 0
            continue
        }

        if ($0 ~ MD_REGEX_TABLE) {
            # debug( "table" )
            if (!md_handle_table( $0, output_arr )) return 0
            continue
        }

        if ($0 ~ MD_REGEX_NOTE) {
            # debug( "note" )
            if (!md_handle_note( $0, output_arr )) return 0
            continue
        }

        # debug( "body:" $0 )
        md_handle_body( $0, output_arr )
    }
}

function md_cat_print(  ){
    return md_handle( MD_GETLINE_ARR, MD_OUTPUT_PRINT )
}

function md_print( input_arr  ){
    return md_handle( input_arr, MD_OUTPUT_PRINT )
}

function md_render( input_arr, output_arr ){
    return md_handle( input_arr, output_arr )
}

function md_cat_render( output_arr ){
    return md_handle( MD_GETLINE_ARR, output_arr )
}
