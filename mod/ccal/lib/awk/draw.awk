BEGIN{
    FS = "\t"
}

BEGIN{
    wmap["周日"] = 0
    wmap["周一"] = 1
    wmap["周二"] = 2
    wmap["周三"] = 3
    wmap["周四"] = 4
    wmap["周五"] = 5
    wmap["周六"] = 6
}

{
    date = $1 # like 1910-05-01	一
    split(date, a, "-")
    yea = int(a[1])
    mon = int(a[2])
    day = int(a[3])
    lunar_day = $4

    ani = $7

    d[day] = lunar_day
    d[day , "w"] = wmap[ $5 ]
    d[day , "W"] = $5

    if ($9 != "无") {
        d[day] = $9
    }

    if (lunar_day == "初一") {
        d[day] = "\033[0;31;1m" $3 " "
    } else {
        d[day] = d[day] " " "\033[0m" "  "
    }

    lastday = day
}

function draw_regular(){
    SP = "  "

    printf("\033[31m" "%s" SP, "周日")
    printf("%s" SP, "周一")
    printf("%s" SP, "周二")
    printf("%s" SP, "周三")
    printf("%s" SP, "周四")
    printf("%s" SP, "周五")
    printf("\033[31m" "%s" SP, "周六")
    printf("\n\n")

    space = d[1 , "w"]
    for (i=1; i<=space; ++i) {
        printf("    " SP)
    }

    for (i=1; i<=lastday; ++i) {
        w = d[ i, "w" ]
        if (w == 0) {
            printf("\033[31m" "%3d " SP, i)
        } else if (w == 6) {
            printf("\033[31m" "%3d " SP, i)
            if ( i != lastday) printf("\n")
        } else {
            printf("\033[0m" "%3d " SP,  i)
        }
    }
    printf("\033[0m\n")
}

BEGIN{
    split(today, a, "/")
    TODAY_Y = a[1]
    TODAY_M = a[2]
    TODAY_D = a[3]

    hlday = ENVIRON["HLDAY"]
    split(hlday, a, "[/-]")
    hl_y = int(a[1])
    hl_m = int(a[2])
    hl_d = int(a[3])
}

function draw_lunar(){
    SP = " " "\033[0m" "  "

    LEADING = "  "

    printf("\n")

    printf(LEADING "\033[1;4m" "                " "\033[1m" "%04d %s年 " "%02d 月"  "               " "\033[0m" SP, yea,  ani , mon)

    printf("\n\n")
    printf(LEADING "\033[31m" "%s" SP, "周日")
    printf("%s" SP, "周一")
    printf("%s" SP, "周二")
    printf("%s" SP, "周三")
    printf("%s" SP, "周四")
    printf("%s" SP, "周五")
    printf("\033[31m" "%s" SP, "周六")
    printf("\n\n")

    space = d[1 , "w"]
    line0 = ""
    for (i=1; i<=space; ++i) {
        line0 = line0 ("    " SP)
    }

    line1 = LEADING line0
    line2 = LEADING line0

    for (i=1; i<=lastday; ++i) {
        w = d[ i, "w" ]
        line1 = line1 "\033[0m"
        line2 = line2 "\033[0m"

        if ((yea == TODAY_Y) && (mon == TODAY_M) && ( i == TODAY_D ) ) {
            line1 = line1 "\033[7;1m"
            line2 = line2 "\033[7;1m"
        }

        if ((yea == hl_y) && (mon == hl_m) && ( i == hl_d ) ) {
            line1 = line1 "\033[46;1m"
            line2 = line2 "\033[46;1m"
        }

        if (w == 0) {
            line1 = line1 sprintf("\033[31m" "%3d "  SP, i)
            line2 = line2 sprintf("\033[2m" "%s", d[i])
        } else if (w == 6) {
            line1 = line1 sprintf("\033[31m" "%3d "  SP, i)
            line2 = line2 sprintf("\033[2m" "%s", d[i])
            if (i != lastday) {
                printf("%s\n%s\n", line1, line2)
                line1 = LEADING
                line2 = LEADING
            }
        } else {
            line1 = line1 sprintf( "%3d " SP,  i)
            line2 = line2 sprintf("\033[2m" "%s", d[i])
        }
    }

    printf("%s\n%s\n", line1, line2)
    printf("\033[0m\n")
}

END{
    draw_lunar()
}

