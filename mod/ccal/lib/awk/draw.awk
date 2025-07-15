BEGIN{
    FS = "\t"
}

{
    datekp = ccal_add( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13 )

    ccal_set( datekp, "lm-zh", lunar_get_month_zh( ccal_lm( datekp ), ccal_ldaycount( datekp )  ) )
    ccal_set( datekp, "ld-zh", lunar_get_day_zh( ccal_ld( datekp ) ) )

    lastkp = datekp
    lastday = ccal_d( datekp )
}

BEGIN{
    ymd_parse( TODAY, "", today )
    ymd_parse( HLDAY, "", ( hlday = ENVIRON["HLDAY"] ) )
}


function draw_lunar_title( _fmt ){
    _fmt = LEADING "\033[1;4m" "                " "\033[1m" "%04d %s年 " "%02d 月"  "               " "\033[0m" SP

    printf(_fmt, ymd_y( o_gdate ),  ani , ymd_m( o_gdate ))
}

BEGIN{
    WD_STYLE = ( wdtitle != "" ) ? wdtitle : ENVIRON[ "CCAL_WD_STYLE" ]
    if  (WD_STYLE == "en")          WD_STYLE_CODE = 0
    else if (WD_STYLE == "xingqi")  WD_STYLE_CODE = 2
    else if (WD_STYLE == "libai")   WD_STYLE_CODE = 3
    else if (WD_STYLE == "yao")     WD_STYLE_CODE = 4
    else                            WD_STYLE_CODE = 1
}

function draw_lunar_wd( start,      i, w, s, SP ){
    SP = " " "\033[0m"

    printf(LEADING)
    if (start == "")    start = 0
    for (i=start; i<=start + 6; ++i) {
        w = i % 7
        s = gongli_wd_name3( w, WD_STYLE_CODE )
        if ( (w == 0) || (w == 6) ) {
            printf("\033[0;31m" "%s" SP,   s )
        } else {
            printf("\033[0m%s" SP,         s )
        }
    }
}

function draw_lunar_gday_style( datekp,     xiuxi ){
    xiuxi = ccal_xiuxi( datekp )
    if (ccal_is_jiaqi( datekp ) ) {
        return "\033[1;31m"
    } else if (xiuxi == "休") {
        return "\033[1;31m"
    } else if (xiuxi == "工") {
        return ""
    } else if (ccal_is_weekend(datekp)) {
        return "\033[31m"
    } else {
        return ""
    }
}

function draw_lunar_lday( datekp ){
    if ( ccal_is_jieqi(datekp) ) {
        return "\033[31m" ccal_jieqi( datekp )            " " "\033[0m" "  "
    } else if ( ccal_is_holiday_gongli( datekp ) ) {
        return "\033[31m" ccal_holiday_gongli( datekp )   " " "\033[0m" "  "
    } else if ( ccal_is_holiday_lunar( datekp ) ) {
        return "\033[31m" ccal_holiday_lunar( datekp )   " " "\033[0m" "  "
    } else if ( ccal_ld( datekp ) == 1 ) {
        if ( ccal_ldaycount( datekp ) == 30 ) {
            return "\033[31;1m" ccal_get( datekp, "lm-zh" ) "\033[0m" " "
        } else {
            return "\033[31;2m" ccal_get( datekp, "lm-zh" ) "\033[0m" " "
        }
    } else {
        return  "\033[2m" ccal_get( datekp, "ld-zh" )   " " "\033[0m" "  "
    }
}

function draw_cal(){
    SP = " " "\033[0m" "  "

    LEADING = "  "

    printf("\n");       draw_lunar_title()

    WD_START = ( wdstart != "" ) ? int( wdstart ) : int( ENVIRON[ "XCAL_WD_START" ] )
    WD_END = ( (WD_START + 6) ) % 7

    printf("\n\n");     draw_lunar_wd( WD_START )
    printf("\n\n")

    ym_kp = ymd_kp_ym( o_gdate )

    space = ( ( ccal_wd( ym_kp SUBSEP 1 ) - WD_START ) + 7 ) % 7
    line0 = ""
    for (i=1; i<=space; ++i) {
        line0 = line0 ("    " SP)
    }

    line1 = LEADING line0
    line2 = LEADING line0


    for (i=1; i<=lastday; ++i) {
        w = ccal_wd( ym_kp SUBSEP i )
        line1 = line1 "\033[0m"
        line2 = line2 "\033[0m"

        if ( ymd_eqymd( TODAY, "",      ymd_y( o_gdate ), ymd_m( o_gdate ), i ) ) {
            line1 = line1 "\033[0;7;1m"
            line2 = line2 "\033[0;7;1m"
        }

        if ( ymd_eqymd( HLDAY, "",   ymd_y( o_gdate ), ymd_m( o_gdate ), i ) ) {
            line1 = line1 "\033[0;46;1m"
            line2 = line2 "\033[0;46;1m"
        }

        line1 = line1 sprintf(draw_lunar_gday_style( ym_kp SUBSEP i ) "%3d " SP, i)
        line2 = line2 sprintf( "%s", draw_lunar_lday( ym_kp SUBSEP i ) )

        if (w == WD_END) {
            if (i != lastday) {
                printf("%s\n%s\n", line1, line2)
                line1 = LEADING
                line2 = LEADING
            }
        }
    }

    printf("%s\n%s\n", line1, line2)
    printf("\033[0m\n")
}

function draw_info( _d, kp, o ){

    ym_kp = ymd_kp_ym( o_gdate )

    if ( hlday == "" ) {
        if ( ! ymd_is_same_month( TODAY, "", o_gdate, "" ) ) return
        _d = ymd_d( TODAY )
    } else {
        _d = ymd_d( HLDAY )
    }

    kp = ym_kp SUBSEP _d

    _line = ""

    xiuxi = ccal_xiuxi( kp )

    _emoji = ccal_emoji( kp )
    if (xiuxi == "休") {
        _line = _line _emoji "  假日 (" ccal_related( kp ) ")"
    } else if (xiuxi == "工") {
        _line = _line _emoji "  工作 (" ccal_related( kp ) ")"
    } else if (ccal_is_weekend(kp)) {
        _line = _line _emoji "  假日 " "周" ccal_wd_zh( kp )
    } else {
        _line = _line _emoji "  工作 " "周" ccal_wd_zh( kp )
    }

    if (ccal_is_holiday_gongli( kp ) ) _line = _line  "  "  ccal_holiday_gongli( kp ) " "
    printf("  %s\n", _line)

    DISABLE_INFO_LUNAR = ( infolunar != "" ) ? infolunar : ENVIRON[ "DISABLE_INFO_LUNAR" ]
    if ( DISABLE_INFO_LUNAR != "disable") {
        draw_info_lunar( kp )
    }


    DISABLE_INFO_YIJI = ( infoyiji != "" ) ? infoyiji : ENVIRON[ "DISABLE_INFO_YIJI" ]
    if ( DISABLE_INFO_YIJI != "disable") {
        printf("\033[31m" "  %s%s\n", "[宜] ", draw_yiji_str( ccal_yi( kp ) ))
        printf("\033[0;32m")
        printf("  %s%s\n", "[忌]", " " draw_yiji_str( ccal_ji( kp ) ))
        printf("\033[0m\n")
    }

    printf("\n")
}

function draw_info_lunar( kp,        _line ){
    _line = ""
    if (ccal_is_jieqi( kp ) )           _line = _line "[节气] " ccal_jieqi( kp ) " " lunar "  \033[2m" lunar_get_jieqi_desc( ccal_jieqi( kp ) ) "\033[0m"
    if (ccal_is_holiday_lunar( kp ) )   _line = _line "[" ccal_holiday_lunar( kp ) "] " ccal_holiday_lunar_desc( kp )
    printf("  %s\n", _line)

    if (ccal_is_holiday_lunar( kp ) ) _line = _line "  " ccal_holiday_lunar( kp ) " "
    printf("  %s %s\t%s\t%s\t%s\n",   "\033[33m" "[轩辕]" "\033[0m",           \
        "\033[33m" lunar_xuanyuan( ccal_ly( kp ) ) "年" "\033[0m",        ccal_lm_zh( kp ) "月",          ccal_get( kp, "ld-zh" ) "日", \
        LUNAR_SX_EMO[ ccal_sx( kp )] " " ccal_sx( kp ) "年" )

    printf("  %s %s\t%s\t%s\n",   "[干支]",           \
        ccal_ygz( kp ) "年",                         ccal_mgz( kp ) "月",            ccal_dgz( kp ) "日"  )

    printf("\033[36m" "  [%s] %s" "\033[0m\n", "值星", ccal_jianchu( kp ) "日" )

    printf("\033[36m" "  [%s] %s" "\033[0m\n", "六曜", ccal_liuyao( kp ) )

    o = ""
    if (ccal_sns( kp )) {
        o =     sprintf("\033[0;7m" "%s" "\033[0m ", "三娘煞")
    }
    if (ccal_ygj( kp )) {
        o = o   sprintf("\033[0;7m" "%s" "\033[0m ", "杨公忌")
    }
    if ( o != "") {
        printf("  [%s] %s\n", "俗忌", o)
    } else {
        printf("\n")
    }
    printf("\033[0m\n")
}

function draw_yiji_str( s,      i, a, l, r ){
    r = "  "
    gsub( "[\r\n]", "", s )  # Notice, there is \r in the data.
    l = split( s, a, " " )
    for (i=1; i<=l; ++i) {
        r = r sprintf("%8s", a[i]) "  "
        if (i%4 == 0) r = r "\n         "
    }
    return r
}

END{
    ymd_new( o_gdate, "",   ccal_y( lastkp ), ccal_m( lastkp ), ccal_d( lastkp ) )
    draw_cal()
    draw_info()
}

