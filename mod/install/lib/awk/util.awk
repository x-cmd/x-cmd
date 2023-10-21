
BEGIN{
    if (NO_COLOR != 1) {
        INSTALL_UI_END          = UI_END
        INSTALL_UI_FG_YELLOW    = UI_FG_YELLOW
        INSTALL_UI_FG_CYAN      = UI_FG_CYAN
        INSTALL_UI_FG_GREEN     = UI_FG_GREEN
    }
}

function print_install_cmd_style(str, reference, install_name){
    if (IS_RUN == 1 ) {
        print "\003\n" str
        return
    }

    if (str ~ "\n") {
        gsub("\n", "\n    ", str)
        str = "|\n    " str
    }

    if (IS_GET == 1) {
        printf("%s%s%s:\n  %scmd%s: %s\n  %sreference%s: %s\n", \
            INSTALL_UI_FG_YELLOW, install_name, INSTALL_UI_END, \
            INSTALL_UI_FG_GREEN, INSTALL_UI_END, str, \
            INSTALL_UI_FG_CYAN, INSTALL_UI_END, reference )
        return
    }
    printf("%s- cmd%s: %s\n  %sreference%s: %s\n", INSTALL_UI_FG_YELLOW, INSTALL_UI_END, str, INSTALL_UI_FG_CYAN, INSTALL_UI_END, reference)
}

