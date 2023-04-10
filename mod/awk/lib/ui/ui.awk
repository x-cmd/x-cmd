BEGIN {
    # https://en.wikipedia.org/wiki/ANSI_escape_code

    UI_FG_BLACK         = "\033[30m"
    UI_FG_RED           = "\033[31m"
    UI_FG_GREEN         = "\033[32m"
    UI_FG_YELLOW        = "\033[33m"
    UI_FG_BLUE          = "\033[34m"
    UI_FG_MAGENTA       = "\033[35m"
    UI_FG_CYAN          = "\033[36m"
    UI_FG_WHITE         = "\033[37m"
    UI_FG_DARKGRAY      = "\033[90m"
    UI_FG_DARKRED       = "\033[91m"

    UI_BG_BLACK         = "\033[40m"
    UI_BG_RED           = "\033[41m"
    UI_BG_GREEN         = "\033[42m"
    UI_BG_YELLOW        = "\033[43m"
    UI_BG_BLUE          = "\033[44m"
    UI_BG_MAGENTA       = "\033[45m"
    UI_BG_CYAN          = "\033[46m"
    UI_BG_WHITE         = "\033[47m"

    UI_END              = "\033[0m"
    UI_TEXT_BOLD        = "\033[1m"
    UI_TEXT_DIM         = "\033[2m"
    UI_TEXT_HID         = "\033[8m"
    UI_TEXT_ITALIC      = "\033[3m"
    UI_TEXT_UNDERLINE   = "\033[4m"
    UI_TEXT_BLINK       = "\033[5m"
    UI_TEXT_REV         = "\033[7m"


    UI_CURSOR_SAVE      = "\0337"
    UI_CURSOR_RESTORE   = "\0338"

    UI_CURSOR_NORMAL    = "\033[34h\033[?25h"
    UI_CURSOR_SHOW      = "\033[34l"
    UI_CURSOR_HIDE      = "\033[?25l"

    UI_SCREEN_SAVE      = "\033[?1049h"
    UI_SCREEN_RESTORE   = "\033[?1049l"

    UI_LINE_CLEAR_RIGHT = "\033[K"
    UI_LINE_CLEAR_LEFT  = "\033[1K"
    UI_LINE_CLEAR       = "\033[2K"

    UI_SCREEN_CLEAR_BOTTOM  = "\033[J"
    UI_SCREEN_CLEAR_TOP     = "\033[1J"
    UI_SCREEN_CLEAR         = "\033[2J"

}


function UI_CURSOR_move_up(number){
    return "\033[" number "A"
}

function uitem(str){
    return str "\033[0m"
}

function ui_goto_cursor(row, column){
    printf "\033[" row ";" column "H"
}

function ui_goto_cursor0(){
    printf "\033[0;0H"
}

function ui_move_next_line(cur_row, cur_col){
    ui_goto_cursor(cur_row + 1, cur_col)
}

function ui_str_rep( str, time,   i, r ){
    for (i=1; i<=time; ++i)     r = r str
    return r
}

function th( style, text ){
    return style text UI_END
}

function th_interval(style,         c){
    style[ SUBSEP "sw" ] = c = 1 - style[ SUBSEP "sw" ]
    return style[ c ]
}

function th_interval_init(style){
    return style[ SUBSEP "sw" ] = 1
}

# BEGIN {
#     print uitem( UI_TEXT_REV UI_FG_RED "hi")
#     print uitem( UI_TEXT_BOLD UI_BG_WHITE UI_FG_CYAN "hi")
# }
