
BEGIN{
    FS = "\t"
}

{
    kp = ccal_add( $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13 )
}

function str_repeat( s, n,      i, r ){
    r = ""
    for(i=1; i<=n; ++i)  r = r s
    return r
}

BEGIN{
    ystr = str_repeat( "%s\t", 8 ) "%s\n"
    mstr = str_repeat( "%s\t", 3 ) "%s\n"
}

function printy(){
    if ( cy == 0 )  return

    xuanyuan = lunar_xuanyuan( cy )
    shengxiao = lunar_get_shengxiao_zh( cy )

    gsub("[ ]$", "", lm_run)

    printf( ystr,    cy, xuanyuan, shengxiao, lmc, lm_run, chunjie, qingming, duanwu, zhongqiu ) > ( output_folder "/year.tsv" )

    lmc = 0
    lm_run = ""
}

function printm(){
    if ( cm == 0 )  return

    ym = sprintf("%04d-%02d", cy, cm)
    xiuxi_gongzuo = ""
    if (tiaoxiu_xiu != "") {
        tiaoxiu_xiu = sprintf("放假 %s", tiaoxiu_xiu)
    }

    if (tiaoxiu_gong != "") {
        tiaoxiu_gong = sprintf("工作 %s", tiaoxiu_gong)
    }

    printf( mstr,  ym, jieqi_list, tiaoxiu_xiu, tiaoxiu_gong ) > ( output_folder "/month.tsv" )
    jieqi_list = ""
    tiaoxiu_gong = ""
    tiaoxiu_xiu = ""
}

{
    lm = ccal_lm( kp )
    ld = ccal_ld( kp )

    m = ccal_m( kp )
    if ( m != cm )  {
        if (lm ~ /a$/)  {
            lm_run = lm_run int(lm) " "
            lmc = lmc + 1
        }
        printm()
    }

    y = ccal_y( kp )
    if ( y != cy )  printy()

    cm = m
    cy = y

    ymd = ccal_ymd( kp )
    md  = ccal_md( kp )

    jieqi = ccal_jieqi( kp )

    if ( ( lm == 1 ) && ( ld == 1) ) {
        chunjie = md
    } else if ( ( lm == 8 ) && ( ld == 15) ) {
        zhongqiu = md
    } else if ( ( lm == 5 ) && ( ld ==  5) ) {
        duanwu = md
    } else if ( jieqi == "清明" ) {
        qingming = md
    }

    if (jieqi != "无") {
        jieqi_list = jieqi_list jieqi " "
    }

    d = ccal_d( kp )
    xiuxi = ccal_xiuxi( kp )
    if ( xiuxi == "工" ) {
        tiaoxiu_gong = tiaoxiu_gong d " "
    } else if (xiuxi == "休") {
        tiaoxiu_xiu = tiaoxiu_xiu d " "
    } else if (ccal_util_is_jiaqi( m, d, lm, ld )) {
        tiaoxiu_xiu = tiaoxiu_xiu d " "
    }
}

END {
    printy()
    printm()
}
