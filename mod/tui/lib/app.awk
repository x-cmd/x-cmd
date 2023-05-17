
BEGIN{
    ___X_CMD_TUI_INPUT_CLOCK_RE="^\001[0-9][0-9]\001[0-9]+\001[0-9]+\001[0-9]?$"

    INDICATOR_CMD = "\001\001\001"
    INDICATOR_FINALCMD = INDICATOR_CMD "\001"
}

function tapp_canvas_rowsize_get(){
    return CANVAS_ROWSIZE
}

function tapp_canvas_colsize_get(){
    return CANVAS_COLSIZE
}

function tapp_init0( rows, cols,  r ){
    if ((rows<3) || (cols<30)) panic("Unable to display content, wrong screen size")
    r = tapp_canvas_rowsize_recalulate( rows )
    if (r <= 0) panic("Screen Size Not Match")

    printf("%s", UI_CURSOR_RESTORE UI_CURSOR_HIDE UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
        str_rep("\r\n", r) painter_up(r) UI_CURSOR_SAVE ) >"/dev/stderr"
    CANVAS_ROWSIZE = (___TAPP_DISPLAYMODE_ == "") ? r : rows - 1
    CANVAS_COLSIZE = cols - 2
}

# Section: display mode
function ___tapp_displaymode_normal_clean(){
    printf("%s", UI_CURSOR_RESTORE UI_SCREEN_SAVE \
        UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR UI_CURSOR_RESTORE \
        space_screen(ROWS, COLS) "\r" painter_up(ROWS) UI_CURSOR_SAVE ) >"/dev/stderr"
}

function ___tapp_displaymode_full_clean(){
    printf("%s", UI_SCREEN_RESTORE "\r" UI_CURSOR_SAVE ) >"/dev/stderr"
}

function ___tapp_displaymode_alter(){
    if (___TAPP_DISPLAYMODE_ == "") {
        ___tapp_displaymode_normal_clean()
        ___TAPP_DISPLAYMODE_ = 1
    }
    else {
        ___tapp_displaymode_full_clean()
        ___TAPP_DISPLAYMODE_ = ""
    }
    ROWS = 0;  COLS = 0;    # Using this to force reset
}
# EndSection

# Section: exit and panic

BEGIN{
    PANIC_EXIT = 0
}
function panic( s ){
    PANIC_EXIT = 1
    PANIC_TEXT = s
    exit(1)
}

function ___tapp_exit_screen_recover(){
    if (___TAPP_DISPLAYMODE_ == "")     ___tapp_displaymode_normal_clean()
    else                                ___tapp_displaymode_full_clean()
}

END{
    ___tapp_exit_screen_recover()
    printf("%s", UI_SCREEN_RESTORE UI_CURSOR_RESTORE \
        space_screen(CANVAS_ROWSIZE+1, COLS) "\r" painter_up(CANVAS_ROWSIZE) \
        UI_CURSOR_RESTORE UI_SCREEN_CLEAR_BOTTOM UI_LINE_CLEAR \
        UI_CURSOR_NORMAL UI_CURSOR_SHOW) >"/dev/stderr"
    tapp_handle_exit( PANIC_EXIT )
    if (PANIC_TEXT != "") log_error("tui", PANIC_TEXT)
    tapp_send_finalcmd( "___X_CMD_TUI_APP_TMP_EXITCODE='" PANIC_EXIT "'" )
    exit( PANIC_EXIT );
}
# EndSection

# ($0 ~ ___X_CMD_TUI_INPUT_CLOCK_RE){
( length($0)>=5 ){
    split($0, a, "\001")
    trigger = (a[5] == 1)? 1 : 0    # a[3] = 1 means true, otherwise means false
    if (trigger) {
        printf("%s\n", "\001"); fflush()
        tapp_handle_response( ___exchange_filepath_get() )
    }

    ROWS_COLS_HAS_CHANGED = false
    if ((a[3] != ROWS) || (a[4] != COLS)) {
        ROWS = a[3]; COLS = a[4]
        ROWS_COLS_HAS_CHANGED = true
        tapp_init0( ROWS, COLS )
    }

    tapp_handle_clocktick(a[2], trigger, CANVAS_ROWSIZE, CANVAS_COLSIZE) # seq, row, column
    next
}

(u8wc($0)){
    if (U8WC_NAME == U8WC_NAME_CANCEL) { # ctrl-X
        ___tapp_displaymode_alter()
        next
    }
    tapp_handle_wchar( U8WC_VALUE, U8WC_NAME, U8WC_TYPE );
}  # handle the wchar: U8WC_TYPE U8WC_VALUE

BEGIN{
    EXCHANGE = 0
    EXCHANGE_CUR = 0
}

function tapp_request( cmd ){
    printf( "%s\n%s\n%s\n%s\n", INDICATOR_CMD, cmd, INDICATOR_CMD, ___exchange_send_filepath_create() )
    fflush()
}

function tapp_send_finalcmd( cmd ){
    printf( "%s\n%s\n%s\n", INDICATOR_FINALCMD, cmd, INDICATOR_FINALCMD )
}

function ___exchange_filepath_get(){
    return FOLDER_ROOT "" ++EXCHANGE_CUR
}

function ___exchange_send_filepath_create(){
    return FOLDER_ROOT "" ++EXCHANGE
}

BEGIN{
    tapp_init0( ROWS, COLS )
    # CANVAS_ROWSIZE = 10
    tapp_init()
}