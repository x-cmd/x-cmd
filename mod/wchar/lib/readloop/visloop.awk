BEGIN{
    printf("\033[1;34mNotce: Press ctrl-c twice to exit.\033[0m\r\n") >"/dev/stderr"
    printf("\033[1;34mFor More Info, please refer awk/lib/u/u8wc.awk\033[0m\r\n\r\n") >"/dev/stderr"
}

{
    if (u8wc($0) == 1) {
        if ( (U8WC_NAME == U8WC_NAME_END_OF_TEXT) && (prev == U8WC_VALUE) ) exit(0)
        prev = U8WC_VALUE

        # print "char:" U8WC_TYPE " " U8WC_VALUE " " U8WC_LEN " " U8WC_ORD >"/dev/stdout"
        # printf("%s\r\n", "char:" U8WC_TYPE " <" U8WC_NAME "> " U8WC_VALUE " ["  U8WC_ORD "] " U8WC_LEN ) >"/dev/stdout"

        if (U8WC_NAME == "") {
            if (U8WC_TYPE == U8WC_TYPE_UPPER) {
                U8WC_NAME = "大写字母" U8WC_VALUE
            } else if (U8WC_TYPE == U8WC_TYPE_LOWER) {
                U8WC_NAME = "小写字母" U8WC_VALUE
            }
        }

        # U8WC_NAME #
        l = wcswidth( U8WC_NAME )
        for (i=1; i<=8-l; ++i) U8WC_NAME = U8WC_NAME " "

        printf("[len=%d] \033[1;32m%-15s\033[0m <\033[1;31m%s\033[0m> [\033[1;35m%3d\033[0m] \033[1;36m%s\033[0m \r\n", U8WC_LEN, U8WC_TYPE, U8WC_NAME, U8WC_ORD, U8WC_VALUE ) >"/dev/stderr"

        # print "char:" U8WC_TYPE " " U8WC_VALUE " " U8WC_LEN " " U8WC_ORD >"abc.txt"


    }
}
