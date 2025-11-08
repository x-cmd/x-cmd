
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
    MONEY_UNIT = ENVIRON[ "money_unit" ]
    USD_RATE_FILE = ( ENVIRON[ "___X_CMD_PRICE_DATA_DIR" ] "/usd-rate.json" )

    prompt_run = "Running ..."
    prompt_end = "Done"

    handle_content_rotate_begin()
}
{
    if ( match($0, "^\\[EXITCODE\\] ") ) {
        STATUS_OBJ[ "EXITCODE" ] = int( substr($0, RLENGTH+1) )
        handle_content_rotate_end()
        exit(0)
    }
    else if ( match($0, "^\\[MODEL-USAGE\\] ") ) {
        OBJ_USAGE_STR = substr($0, RLENGTH+1)
        next
    }
    else if ( match($0, "^\\[MODEL-SENT-AT\\] ") ) {
        MODEL_SENT_AT = substr($0, RLENGTH+1)
        next
    }
    else if ( match($0, "^\\[MODEL-RECV-AT\\] ") ) {
        MODEL_RECV_AT = substr($0, RLENGTH+1)
        next
    }
    else if ( $0 == "[MODEL-RES-START]" ) {
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
        l = OUTPUT_ARR[ L ]
        if (( l > 1 ) || ( OUTPUT_ARR[1] != "" )) {
            if ( is_interactive ) {
                handle_content_md( OUTPUT_ARR )
            } else {
                for (i=1; i<=l; ++i) print OUTPUT_ARR[i]
            }
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

function handle_usage_format_currency(totalprice,           amount){
    if ( totalprice <= 0 ) return
    if ( (CCY_OBJ[ Q2_1, L ] > 0 ) || jiparse2leaf_fromfile( CCY_OBJ, Q2_1, USD_RATE_FILE ) ) {
        amount = llmp_usd_to_currency( CCY_OBJ, Q2_1, MONEY_UNIT, totalprice )
        return llmp_format_currency( amount, MONEY_UNIT )
    }
}

function handle_usage(str,          o, kp_usage, total_token, at, sat, it, ot, ict, icr, ott, otr, _time_str, _cache_str, _thought_str, isr, ihr, ior, detail_str, _money_tp, _money_stp, tp, stp ) {
    if ( (MODEL_SENT_AT != "") && (MODEL_RECV_AT != "")){
        _time_str = date_epochminus(MODEL_RECV_AT, MODEL_SENT_AT)
        if ( _time_str != "" ) _time_str = date_humantime( _time_str )
    }

    if ( str == "" ) {
        if ( _time_str != "" ) detail_str = "Time: " _time_str
    } else {
        jiparse_after_tokenize(o, str)
        kp_usage = Q2_1 SUBSEP "\"usage\""
        at = int( o[ kp_usage SUBSEP "\"total\"" SUBSEP "\"token\"" ] )
        sat = int( o[ kp_usage SUBSEP "\"session\"" SUBSEP "\"token\"" ] )
        if ( at <= 0 ) {
            if ( _time_str != "" ) detail_str = "Time: " _time_str
        } else {
            it = int( o[ kp_usage SUBSEP "\"input\""  SUBSEP "\"token\"" ] )
            ot = int( o[ kp_usage SUBSEP "\"output\"" SUBSEP "\"token\"" ] )

            ict =  int( o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"cache_token\"" ] )
            icr =  o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio_cache\"" ]
            if ( ict > 0 ) icr = sprintf( "%.4f", (ict/it) )
            if ( icr > 0 ) _cache_str = " (Cache " icr * 100 "%)"

            ott = int( o[ kp_usage SUBSEP "\"output\"" SUBSEP "\"thought_token\"" ] )
            if ( ott > 0 ) otr = sprintf("%.4f", (ott/ot) )
            if ( otr > 0 ) _thought_str = " (Thought " otr * 100 "%)"

            isr = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio_system\"" ]
            ihr = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio_history\"" ]
            ior = o[ kp_usage SUBSEP "\"input\"" SUBSEP "\"ratio_other\"" ]

            tp  = o[ kp_usage SUBSEP "\"total\"" SUBSEP "\"price\"" ]
            stp = o[ kp_usage SUBSEP "\"session\"" SUBSEP "\"price\"" ]

            if (tp > 0)     _money_tp  = " | " handle_usage_format_currency( tp )
            if (stp > 0)    _money_stp = " | " handle_usage_format_currency( stp )
            if ( _time_str != "" ) _time_str = " | " _time_str

            detail_str =                        sprintf("Now   → Token %s = In %s + Out %s%s%s", at, it _cache_str, ot _thought_str, _money_tp, _time_str ) "\n"
            detail_str = detail_str             sprintf("Dist  → Sys %s | Hist %s | Other %s",  isr * 100 "%", ihr * 100 "%", ior * 100 "%")
            if (sat > at) {
                detail_str = detail_str "\n"    sprintf("Total → Token %s%s", sat, _money_stp )
            }
        }
    }
    if ( detail_str != "" ) print "\033[90m" detail_str "\033[0m"
}
