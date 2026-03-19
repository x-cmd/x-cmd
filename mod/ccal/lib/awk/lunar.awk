BEGIN{
    LUNAR_FESTIVAL[ 1 ,  1 ]    = "春联, 守岁, 鞭炮, 拜年, 利是压岁"
    LUNAR_FESTIVAL[ 1 , 15 ]    = "观花灯, 猜灯谜, 吃元宵, 舞龙狮"
    LUNAR_FESTIVAL[ 2 ,  1 ]    = "春社, 土地诞, 祭祀土地, 祈求丰收"
    LUNAR_FESTIVAL[ 2 ,  2 ]    = "理发, 龙须面, 祈求风调雨顺"
    LUNAR_FESTIVAL[ 2 , 15 ]    = "百花生日: 赏花, 祭花神, 踏青游春"
    LUNAR_FESTIVAL[ 3 ,  3 ]    = "黄帝祭, 轩辕节; 踏青游春, 临水宴饮, 曲水流觞"
    LUNAR_FESTIVAL[ 5 ,  5 ]    = "屈原祭, 吃粽子, 赛龙舟, 挂艾草, 佩香囊"
    LUNAR_FESTIVAL[ 7 ,  7 ]    = "牛郎织女, 乞巧节; 穿针引线, 祈求巧艺"
    LUNAR_FESTIVAL[ 7 , 15 ]    = "盂兰盆节, 祭祖, 放河灯"
    LUNAR_FESTIVAL[ 8 , 15 ]    = "团聚, 赏月, 桂花, 灯笼"
    LUNAR_FESTIVAL[ 9 ,  9 ]    = "登高, 赏菊, 插茱萸, 饮菊花酒"
    LUNAR_FESTIVAL[ 10,  1 ]    = "送寒衣, 祭祀祖先, 为亡者送冬衣"
    LUNAR_FESTIVAL[ 10, 15 ]    = "水官诞, 祭祀水官, 祈求平安"
    LUNAR_FESTIVAL[ 12,  8 ]    = "佛祖成道, 燃灯, 喝腊八粥, 祭祖, 敬神, 感恩"
    LUNAR_FESTIVAL[ 12, 23 ]    = "小年(官); 送灶神, 糖瓜粘, 扫尘, 准备过年"
    LUNAR_FESTIVAL[ 12, 24 ]    = "小年(民); 送灶神, 糖瓜粘, 扫尘, 准备过年"
    LUNAR_FESTIVAL[ 12, 25 ]    = "小年(船); 送灶神, 糖瓜粘, 扫尘, 准备过年"
}

BEGIN{
    LUNAR_FESTIVAL_S[ 1 ,  1 ]    = "春节"
    LUNAR_FESTIVAL_S[ 1 , 15 ]    = "元宵"
    LUNAR_FESTIVAL_S[ 2 ,  1 ]    = "中和" # "春社 土地诞"
    LUNAR_FESTIVAL_S[ 2 ,  2 ]    = "龙头" # "春社 土地诞"
    LUNAR_FESTIVAL_S[ 2 , 15 ]    = "花朝" # "春社 土地诞"
    LUNAR_FESTIVAL_S[ 3 ,  3 ]    = "上巳";           LUNAR_FESTIVAL_DESC[ 3 ,  3 ]    = "黄帝祭, 轩辕节; 上巳, 可踏青游春, 临水宴饮, 曲水流觞"
    LUNAR_FESTIVAL_S[ 5 ,  5 ]    = "端午"
    LUNAR_FESTIVAL_S[ 7 ,  7 ]    = "七夕"
    LUNAR_FESTIVAL_S[ 7 , 15 ]    = "中元"
    LUNAR_FESTIVAL_S[ 8 , 15 ]    = "中秋"
    LUNAR_FESTIVAL_S[ 9 ,  9 ]    = "重阳"
    LUNAR_FESTIVAL_S[ 10,  1 ]    = "寒衣"
    LUNAR_FESTIVAL_S[ 10, 15 ]    = "下元"
    LUNAR_FESTIVAL_S[ 12,  8 ]    = "腊八"
    LUNAR_FESTIVAL_S[ 12, 23 ]    = "祭灶"
    LUNAR_FESTIVAL_S[ 12, 24 ]    = "祭灶"
    LUNAR_FESTIVAL_S[ 12, 25 ]    = "祭灶"
}

function lunar_get_festival_short( m, d,   n1, n2,     r ){
    if (( r = LUNAR_FESTIVAL_S[ int(m), int(d) ] ) != "")  return r

    # TODO: how to calculate 寒食和小寒食 ( 清明节 1, 2 )
    # TODO: 除夕, 春节前一天
    return ""
}

function lunar_get_festival( m, d,   n1, n2,     r ){
    if (( r = LUNAR_FESTIVAL[ int(m), int(d) ] ) != "")  return r

    # TODO: how to calculate 寒食和小寒食 ( 清明节 1, 2 )
    # TODO: 除夕, 春节前一天
    return ""
}

function lunar_get_festival_desc( m, d,   n1, n2,     r ){
    if (( r = LUNAR_FESTIVAL_DESC[ int(m), int(d) ] ) != "")  return r
    return ( lunar_get_festival( m, d ) )
}


BEGIN{
    JIEQI_DESC[ "立春" ] = "东风解冻，万物复苏"
    JIEQI_DESC[ "雨水" ] = "春雨润物，草木萌动"
    JIEQI_DESC[ "惊蛰" ] = "春雷乍动，万物生长"
    JIEQI_DESC[ "春分" ] = "昼夜平分，春色正中"
    JIEQI_DESC[ "清明" ] = "清风明月，踏青祭祖"
    JIEQI_DESC[ "谷雨" ] = "雨生百谷，播种新耕"
    JIEQI_DESC[ "立夏" ] = "万物并秀，夏意渐浓"
    JIEQI_DESC[ "小满" ] = "麦穗初齐，物至于此"
    JIEQI_DESC[ "芒种" ] = "有芒之谷，忙于插秧"
    JIEQI_DESC[ "夏至" ] = "日长之至，万物繁茂"
    JIEQI_DESC[ "小暑" ] = "温风至，暑气渐盛"
    JIEQI_DESC[ "大暑" ] = "炎炎盛夏，骄阳似火"
    JIEQI_DESC[ "立秋" ] = "凉风至，万物渐收"
    JIEQI_DESC[ "处暑" ] = "暑气渐消，秋意初现"
    JIEQI_DESC[ "白露" ] = "露凝而白，秋意渐浓"
    JIEQI_DESC[ "秋分" ] = "昼夜均分，秋色平分"
    JIEQI_DESC[ "寒露" ] = "露气寒冷，草木黄落"
    JIEQI_DESC[ "霜降" ] = "初霜降临，万物肃杀"
    JIEQI_DESC[ "立冬" ] = "水始冰，地始冻"
    JIEQI_DESC[ "小雪" ] = "寒气渐增，初雪未盛"
    JIEQI_DESC[ "大雪" ] = "雪深千里，天地银装"
    JIEQI_DESC[ "冬至" ] = "白昼最短，阳气初生"
    JIEQI_DESC[ "小寒" ] = "寒气渐深，岁暮天寒"
    JIEQI_DESC[ "大寒" ] = "岁寒隆冬，冰封大地"
}

function lunar_get_jieqi_desc( key ){
    return JIEQI_DESC[ key ]
}

BEGIN{
    # TODO: 除夕 ?
    LUNAR_JIA[ 1 ,  1 ]    = "春节"
    LUNAR_JIA[ 1 ,  2 ]    = "春节"
    LUNAR_JIA[ 1 ,  3 ]    = "春节"

    LUNAR_JIA[ 5 ,  5 ]    = "端午"
    LUNAR_JIA[ 8 , 15 ]    = "中秋"
}

function lunar_is_jiaqi( m, d){
    return LUNAR_JIA[ int(m), int(d) ]
}

BEGIN{

    LUNAR_D[ 0 ] = "零"
    LUNAR_D[ 1 ] = "一"
    LUNAR_D[ 2 ] = "二"
    LUNAR_D[ 3 ] = "三"
    LUNAR_D[ 4 ] = "四"
    LUNAR_D[ 5 ] = "五"
    LUNAR_D[ 6 ] = "六"
    LUNAR_D[ 7 ] = "七"
    LUNAR_D[ 8 ] = "八"
    LUNAR_D[ 9 ] = "九"
    LUNAR_D[ 10 ] = "十"
    LUNAR_D[ 11 ] = "十一"
    LUNAR_D[ 12 ] = "十二"

    LUNAR_D[ 20 ] = "廿十"
    LUNAR_D[ 30 ] = "三十"
}

function lunar_get_day_zh( d,      n ){
    d = int(d)
    if (d == 10)        return "初十"
    else if (d == 20)   return "二十"
    else if (d == 30)   return "三十"
    else if (d <  10)   return "初" LUNAR_D[d]
    else if (d <  20)   return "十" LUNAR_D[d-10]
    else                return "廿" LUNAR_D[d-20]
}

# Fixed width -- 3 wchar
function lunar_get_month_zh( m, daycount,       mi ){
    e = ( daycount == 30) ? "大" : "小"

    mi = int(m)
    mi = ( (mi > 10) ? LUNAR_D[ mi ] : (LUNAR_D[ mi ] "月") )

    # Notice: "\033[0m" is tmp fixed for highlight style
    return (m ~ /a$/) ? ( "闰" mi ) : ( mi " " "\033[0m" " " )
}

BEGIN{
    LUNAR_SHENGXIAO[ 0,  1 ] = "鼠"
    LUNAR_SHENGXIAO[ 1,  1 ] = "牛"
    LUNAR_SHENGXIAO[ 2,  1 ] = "虎"
    LUNAR_SHENGXIAO[ 3,  1 ] = "兔"
    LUNAR_SHENGXIAO[ 4,  1 ] = "龙"
    LUNAR_SHENGXIAO[ 5,  1 ] = "蛇"
    LUNAR_SHENGXIAO[ 6,  1 ] = "马"
    LUNAR_SHENGXIAO[ 7,  1 ] = "羊"
    LUNAR_SHENGXIAO[ 8,  1 ] = "猴"
    LUNAR_SHENGXIAO[ 9,  1 ] = "鸡"
    LUNAR_SHENGXIAO[ 10, 1 ] = "狗"
    LUNAR_SHENGXIAO[ 11, 1 ] = "猪"
}

function lunar_get_shengxiao_zh( y ){
    return LUNAR_SHENGXIAO[ (y-4) % 12, 1 ]
}

BEGIN{
    LUNAR_LIUYAO[ 0 ] = "大安"
    LUNAR_LIUYAO[ 1 ] = "赤口"
    LUNAR_LIUYAO[ 2 ] = "先胜"
    LUNAR_LIUYAO[ 3 ] = "友引"
    LUNAR_LIUYAO[ 4 ] = "先负"
    LUNAR_LIUYAO[ 5 ] = "佛灭"
}

function lunar_liuyao( m, d ){
    return LUNAR_LIUYAO[(int(m) + int(d)) % 6]
}

BEGIN{
    LUNAR_SNS[ 3 ] = LUNAR_SNS[ 7 ] = LUNAR_SNS[ 13 ] = LUNAR_SNS[ 18 ] = LUNAR_SNS[ 23 ] = LUNAR_SNS[ 27 ] = 1
}

function lunar_sns( d, riganzhi ) {
    if ( ( d ==  3 ) && ( riganzhi == "庚午") )  return 1
    if ( ( d ==  7 ) && ( riganzhi == "辛未") )  return 1
    if ( ( d == 13 ) && ( riganzhi == "戊申") )  return 1
    if ( ( d == 19 ) && ( riganzhi == "己酉") )  return 1
    if ( ( d == 22 ) && ( riganzhi == "丙午") )  return 1
    if ( ( d == 27 ) && ( riganzhi == "丁未") )  return 1
    return 0

}

function lunar_xuanyuan( y ) {
    return int( y ) + 2697
}

function lunar_foto( y, m, d ) {
    y = (int( y ) + 543) # 第三届佛教大会
    return ((m>4) || ((m==4) && (d>=15))) ? (y+1) : y
}


BEGIN{
    LUNAR_YANGJI[  1, 13 ]  = 1
    LUNAR_YANGJI[  2, 11 ]  = 1
    LUNAR_YANGJI[  3,  9 ]  = 1
    LUNAR_YANGJI[  4,  7 ]  = 1
    LUNAR_YANGJI[  5,  5 ]  = 1
    LUNAR_YANGJI[  6,  3 ]  = 1
    LUNAR_YANGJI[  7,  1 ]  = 1
    LUNAR_YANGJI[  7, 29 ]  = 1
    LUNAR_YANGJI[  8, 27 ]  = 1
    LUNAR_YANGJI[  9, 25 ]  = 1
    LUNAR_YANGJI[ 10, 23 ]  = 1
    LUNAR_YANGJI[ 11, 21 ]  = 1
    LUNAR_YANGJI[ 12, 19 ]  = 1
}

function lunar_is_yangji( m, d ) {
    return LUNAR_YANGJI[ int(m), int(d) ] == 1
}


function lunar_is_xiong( m, d ){
    return (lunar_is_yangji( m, d ) * 1000) + (lunar_sns( m, d ) * 100 ) + 0
}

BEGIN {
    LUNAR_SX_EMO[ "鼠" ] = "🐭"
    LUNAR_SX_EMO[ "牛" ] = "🐮"
    LUNAR_SX_EMO[ "虎" ] = "🐯"
    LUNAR_SX_EMO[ "兔" ] = "🐰"
    LUNAR_SX_EMO[ "龙" ] = "🐲"
    LUNAR_SX_EMO[ "蛇" ] = "🐍"
    LUNAR_SX_EMO[ "马" ] = "🐴"
    LUNAR_SX_EMO[ "羊" ] = "🐑"
    LUNAR_SX_EMO[ "猴" ] = "🐵"
    LUNAR_SX_EMO[ "鸡" ] = "🐔"
    LUNAR_SX_EMO[ "狗" ] = "🐶"
    LUNAR_SX_EMO[ "猪" ] = "🐷"
}
