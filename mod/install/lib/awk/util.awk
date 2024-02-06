
BEGIN{
    if (NO_COLOR != 1) {
        INSTALL_UI_END          = UI_END
        INSTALL_UI_FG_YELLOW    = UI_FG_YELLOW
        INSTALL_UI_FG_CYAN      = UI_FG_CYAN
        INSTALL_UI_FG_GREEN     = UI_FG_GREEN
        INSTALL_UI_FG_BLUE      = UI_FG_BLUE
    }
}

function print_install_cmd_style(str, reference, install_name){
    str = str_trim(str)
    if (IS_RUN == 1 ) {
        printf (" \\\n%s", qu1(str))
        return
    }

    if (str ~ "\n") {
        gsub("\n", "\n    ", str)
        str = "|\n    " str
    }

    if (IS_GET == 1) {
        printf("%s%s%s:\n  %s%s%s: %s\n  %s%s%s: %s\n", \
            INSTALL_UI_FG_YELLOW,   install_name,   INSTALL_UI_END, \
            INSTALL_UI_FG_GREEN,    "cmd",          INSTALL_UI_END, str, \
            INSTALL_UI_FG_CYAN,     "reference",    INSTALL_UI_END, reference )
        return
    }
    printf("- %s%s%s: %s\n  %s%s%s: %s\n", \
        INSTALL_UI_FG_CYAN,     "reference",    INSTALL_UI_END, reference, \
        INSTALL_UI_FG_YELLOW,   "cmd",          INSTALL_UI_END, str )
}

function print_install_basic_info_style(name, homepage, desc, lang){
    if (IS_RUN != 1 ){
        printf("- %s%s%s: %s\n- %s%s%s: %s\n- %s%s%s: %s\n- %s%s%s: %s\n\n", \
        INSTALL_UI_FG_GREEN,     "Name",          INSTALL_UI_END, name, \
        INSTALL_UI_FG_GREEN,     "Homepage",      INSTALL_UI_END, homepage, \
        INSTALL_UI_FG_GREEN,     "Description",   INSTALL_UI_END, desc,
        INSTALL_UI_FG_GREEN,     "Language",      INSTALL_UI_END, lang )
    }
}

