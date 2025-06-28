
BEGIN{
    GONGLI_D_CN[ GONGLI_D[  1,  1 ]         = "New Year" ]              = "元旦"
    GONGLI_D_CN[ GONGLI_D[  2, 14 ]         = "Valentines' Day" ]       = "情人"
    GONGLI_D_CN[ GONGLI_D[  3,  8 ]         = "Women's Day" ]           = "妇女"
    GONGLI_D_CN[ GONGLI_D[  3, 12 ]         = "Arbor Day" ]             = "植树"
    GONGLI_D_CN[ GONGLI_D[  4,  1 ]         = "April Fools' Day" ]      = "愚人"
    GONGLI_D_CN[ GONGLI_D[  5,  1 ]         = "Labor Day" ]             = "劳动"
    GONGLI_D_CN[ GONGLI_D[  5,  4 ]         = "Youth Day" ]             = "青年"
    GONGLI_D_CN[ GONGLI_D[  6,  1 ]         = "Children's Day" ]        = "儿童"
    GONGLI_D_CN[ GONGLI_D[  7,  1 ]         = "CPC Founding Day" ]      = "建党"
    GONGLI_D_CN[ GONGLI_D[  8,  1 ]         = "Army Day" ]              = "建军"
    GONGLI_D_CN[ GONGLI_D[  9,  3 ]         = "Victory Day" ]           = "胜利"
    GONGLI_D_CN[ GONGLI_D[  9, 10 ]         = "Teachers' Day" ]         = "教师"
    GONGLI_D_CN[ GONGLI_D[ 10,  1 ]         = "Chinese National Day" ]  = "国庆"
    GONGLI_D_CN[ GONGLI_D[ 10, 31 ]         = "Halloween" ]             = "万圣"

    GONGLI_D_CN[ "Mothers's Day" ]          = "母亲"
    GONGLI_D_CN[ "Father's Day" ]           = "父亲"
    GONGLI_D_CN[ "Thanks's Giving Day" ]    = "感恩"
}

function get_gongli_holiday( m, d, wd,      r ){
    if ( ( r = GONGLI_D[ int(m), int(d) ] ) != "" ) return r

    if ((m==5)  && (wd == 0) && (d>=8)  && (d<15))  return "Mothers's Day"
    if ((m==6)  && (wd == 0) && (d>=15) && (d<22)) return "Father's Day"
    if ((m==11) && (wd == 4) && (d>=26)) return "Thanks's Giving Day"
}

function get_gongli_holiday_zh( m, d, wd,      r ){
    return GONGLI_D_CN[ get_gongli_holiday( m, d, wd )]
}


BEGIN{
    GONGLI_JIA[  1,  1 ]  = "元旦"

    GONGLI_JIA[  5,  1 ]  = "劳动"
    GONGLI_JIA[  5,  2 ]  = "劳动"

    GONGLI_JIA[ 10,  1 ]  = "国庆"
    GONGLI_JIA[ 10,  2 ]  = "国庆"
    GONGLI_JIA[ 10,  3 ]  = "国庆"
}

function gongli_is_jiaqi( m, d ){
    return GONGLI_JIA[ int(m), int(d) ] != ""

}

BEGIN{
    GONGLI_WD_CHAR_EN[ 0 ]  = "Sun."
    GONGLI_WD_CHAR_EN[ 1 ]  = "Mon."
    GONGLI_WD_CHAR_EN[ 2 ]  = "Tue."
    GONGLI_WD_CHAR_EN[ 3 ]  = "Wed."
    GONGLI_WD_CHAR_EN[ 4 ]  = "Thu."
    GONGLI_WD_CHAR_EN[ 5 ]  = "Fri."
    GONGLI_WD_CHAR_EN[ 6 ]  = "Sat."
}

BEGIN{
    GONGLI_WD_CHAR_ZH[ 0 ]  = "日"
    GONGLI_WD_CHAR_ZH[ 1 ]  = "一"
    GONGLI_WD_CHAR_ZH[ 2 ]  = "二"
    GONGLI_WD_CHAR_ZH[ 3 ]  = "三"
    GONGLI_WD_CHAR_ZH[ 4 ]  = "四"
    GONGLI_WD_CHAR_ZH[ 5 ]  = "五"
    GONGLI_WD_CHAR_ZH[ 6 ]  = "六"
}

BEGIN {
    GONGLI_WD_YAO[ 0 ]      = "日曜"
    GONGLI_WD_YAO[ 1 ]      = "月曜"
    GONGLI_WD_YAO[ 2 ]      = "火曜"
    GONGLI_WD_YAO[ 3 ]      = "水曜"
    GONGLI_WD_YAO[ 4 ]      = "木曜"
    GONGLI_WD_YAO[ 5 ]      = "金曜"
    GONGLI_WD_YAO[ 6 ]      = "土曜"
}

function gongli_wd_name_en( id ){           return(             GONGLI_WD_CHAR_EN[  id ] ); }
function gongli_wd_name_zhou( id ){         return( "周"        GONGLI_WD_CHAR_ZH[  id ]); }
function gongli_wd_name_xingqi( id ){       return( "星期"      GONGLI_WD_CHAR_ZH[  id ]); }
function gongli_wd_name_libai( id ){        return( "礼拜"      GONGLI_WD_CHAR_ZH[  id ]); }
function gongli_wd_name_yao( id ){          return(             GONGLI_WD_YAO[      id ]); }

BEGIN{
    GONGLI_WD_STYLE_EN      = 0
    GONGLI_WD_STYLE_ZHOU    = 1
    GONGLI_WD_STYLE_XINGQI  = 2
    GONGLI_WD_STYLE_LIBAI   = 3
    GONGLI_WD_STYLE_YAO     = 4
}

function gongli_wd_name( id,    style ){
    if (style == GONGLI_WD_STYLE_EN)        return gongli_wd_name_en( id )
    if (style == GONGLI_WD_STYLE_XINGQI)    return gongli_wd_name_xingqi( id )
    if (style == GONGLI_WD_STYLE_LIBAI)     return gongli_wd_name_libai( id )
    if (style == GONGLI_WD_STYLE_YAO)       return gongli_wd_name_yao( id )

    return gongli_wd_name_zhou( id )
}
