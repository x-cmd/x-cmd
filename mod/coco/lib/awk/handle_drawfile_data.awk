
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

function handle_usage(str,          o, kp_usage, total_token, at, it, ot, ict, icr, ott, otr, _cache_str, _thought_str, isr, ihr, ior, detail_str, model, provider, PRICE_DATA_DIR, price_data_file, usd_rate_file, currency, llmp_obj, ccy_obj, llmp_it, llmp_model, totalprice, amount, _amount_str) {
    if ( str == "" ) return
    jiparse_after_tokenize(o, str)
    kp_usage = Q2_1 SUBSEP "\"usage\""
    at = int( o[ kp_usage SUBSEP "\"total\""  SUBSEP "\"tokens\"" ] )
    if ( at <= 0 ) return
    it = int( o[ kp_usage SUBSEP "\"input\""  SUBSEP "\"tokens\"" ] )
    ot = int( o[ kp_usage SUBSEP "\"output\"" SUBSEP "\"tokens\"" ] )

    ict =  int( o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"cache_tokens\"" ] )
    icr =  o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio\"" SUBSEP "\"cache\"" ]
    if ( ict > 0 ) icr = sprintf( "%.4f", (ict/it) )
    if ( icr > 0 ) _cache_str = " (Cache " icr * 100 "%)"

    ott = int( o[ kp_usage SUBSEP "\"output\"" SUBSEP "\"thought_tokens\"" ] )
    if ( ott > 0 ) otr = sprintf("%.4f", (ott/ot) )
    if ( otr > 0 ) _thought_str = " (Thought " otr * 100 "%)"

    isr = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio\"" SUBSEP "\"system\"" ]
    ihr = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio\"" SUBSEP "\"history\"" ]
    ior = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio\"" SUBSEP "\"other\"" ]

    model = o[ Q2_1 SUBSEP "\"model\"" ]
    provider = o[ Q2_1 SUBSEP "\"provider\"" ]
    PRICE_DATA_DIR = ENVIRON[ "___X_CMD_PRICE_DATA_DIR" ]
    price_data_file = PRICE_DATA_DIR "/" juq(provider) "/latest.json"
    usd_rate_file = PRICE_DATA_DIR "/usd-rate.json"
    currency = "USD"
    if ( jiparse2leaf_fromfile( llmp_obj, Q2_1, price_data_file ) && jiparse2leaf_fromfile( ccy_obj, "ccykp", usd_rate_file )  ) {
        llmp_model = llmp_search_model( llmp_obj, Q2_1, model )
        llmp_it = it - ict
        if ( llmp_model != "" ) {
            totalprice = llmp_total_calprice( llmp_obj, Q2_1, llmp_model, llmp_it, ict, ot )
            amount = llmp_amount_calccy( ccy_obj, Q2_1, currency, totalprice )
            _amount_str = "· Cost: " llmp_format_ccy( amount, currency )
        }
    }

    detail_str = sprintf("Token: %s = Input %s + Output %s %s", at, it _cache_str, ot _thought_str, _amount_str ) "\n" \
        sprintf("Input distribution → Sys %s | Hist %s | Other %s",  isr * 100 "%", ihr * 100 "%", ior * 100 "%")
    print "\033[90m" detail_str "\033[0m"
}
