
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
        }
    }
}

function handle_content_md(arr){
    ARR_L = arr[ L ]
    hd_main( arr )
}

function handle_usage(str,          o, kp_usage, l, k, v, _l, j, jk, jv){
    if ( str == "" ) return
    jiparse_after_tokenize(o, str)
    kp_usage = Q2_1 SUBSEP "\"usage\""

    handle_usage_unit( "usage" )
    l = o[ kp_usage L ]
    for (i=1; i<=l; ++i){
        k = o[ kp_usage, i ]
        v = o[ kp_usage, k ]
        if ( k ~ "details" ) continue
        if (v == "{") {
            handle_usage_unit( k, "", "  " )
            _l = o[ kp_usage, k L ]
            for (j=1; j<=_l; ++j){
                jk = o[ kp_usage, k, j ]
                jv = o[ kp_usage, k, jk ]
                handle_usage_unit( jk, jv, "    " )
            }
            continue
        }
        handle_usage_unit( k, v, "  " )
    }
}

function handle_usage_unit( k, v, indent ) {
    v = (v ~ "^\"") ? juq(v) : v
    k = (k ~ "^\"") ? juq(k) : k
    print indent "\033[36m" k "\033[0m: \033[35m" v "\033[0m"
}
