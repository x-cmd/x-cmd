
BEGIN{
    Q2_1 = SUBSEP "\"1\""

    ROWS = int(ENVIRON[ "LINES" ])
    ROWS = int(ROWS/3)
    ROWS = ( ROWS > 5 ) ? ROWS : 5
    SIZE = 10
    if (SIZE > ROWS) SIZE = int(ENVIRON[ "LINES" ]) -3
    if (SIZE <= 0) SIZE = ROWS

    EXITCLEAR  = 1
    OUTPUT_RAW = 1
    is_interactive = ENVIRON[ "is_interactive" ]

    prompt_run = "Running ..."
    prompt_end = "Done"

    handle_content_rotate_begin()
}
{
    if ( $0 ~ "^\\[EXITCODE\\] " ) {
        STATUS_OBJ[ "EXITCODE" ] = int( substr($0, 12) )
        handle_content_rotate_end()
        exit(0)
    }
    else if ( $0 ~ "^\\[USAGE\\] " ) {
        OBJ_USAGE_STR = substr($0, 9)
        next
    }
    else if ( $0 == "[START]" ) {
        handle_content_rotate_end()
        handle_content_rotate_begin()
        OBJ_USAGE_STR = ""
        next
    }
    else if ($0 ~ "^    "){
        if ( ! is_interactive ) {
            OUTPUT_ARR[ ++ OUTPUT_ARR[ L ]  ] = substr($0, 5)
        } else {
            ui_rotate___handle_running( RING_ARR, OUTPUT_ARR, STATUS_OBJ, substr($0, 5), "", prompt_run, OUTPUT_RAW )
        }
        next
    }
}

END{
    _c = int( STATUS_OBJ[ "EXITCODE" ] )
    if ( _c == 0 ) {
        if ( is_interactive ) {
            handle_content_md( OUTPUT_ARR )
        } else {
            l = OUTPUT_ARR[ L ]
            for (i=1; i<=l; ++i) print OUTPUT_ARR[i]
        }
    }

    if ( is_interactive ) {
        handle_usage( OBJ_USAGE_STR )
    }
    exit( _c )
}

function handle_content_rotate_begin(){
    if ( is_interactive ) {
        ui_rotate_render_begin(SIZE)
        ring_init( RING_ARR, SIZE )
    }

    delete OUTPUT_ARR
}
function handle_content_rotate_end(){
    if ( is_interactive ) {
        if ( STATUS_OBJ[ "HAS_CONTENT" ] ) {
            ui_rotate_render_prompt( RING_ARR )
            if ( EXITCLEAR == 1 )   ui_rotate_render_clear()
            ui_rotate_render_restore()
            STATUS_OBJ[ "HAS_CONTENT" ] = 0
        }
    }
}

function handle_content_md(arr){
    ARR_L = arr[ L ]
    hd_main( arr )
}

function handle_usage(str,          o, kp_usage, total_token, pt, ct, tt, detail_str ){
    if ( str == "" ) return
    jiparse_after_tokenize(o, str)
    kp_usage = Q2_1 SUBSEP "\"usage\""
    total_token = int( o[ kp_usage SUBSEP "\"total_tokens\"" ] )
    pt = int( o[ kp_usage SUBSEP "\"prompt_tokens\"" ] )
    ct = int( o[ kp_usage SUBSEP "\"completion_tokens\"" ] )
    tt = int( o[ kp_usage SUBSEP "\"thought_tokens\"" ] )
    # model           = juq( o[ Q2_1 SUBSEP "\"model\"" ] )

    detail_str = pt " prompt, " ct " completion"
    if ( tt > 0 ) detail_str = detail_str ", " tt " thought"
    print "\033[90m    Usage: " total_token " tokens (" detail_str ")\033[0m"
}
