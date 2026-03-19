
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
