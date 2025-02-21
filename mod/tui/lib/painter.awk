
function painter_reset(){
    return UI_CURSOR_RESTORE    # "\0338"
}

function painter_init( x, y ){
    return painter_reset() painter_goto( x, y )
}

function painter_savepos(){
    return UI_CURSOR_SAVE       # "\0337"
}

function painter_goto( x, y ){
    return "\033[" x ";" y "H"
}

function painter_goto_rel( x, y ){
    return UI_CURSOR_RESTORE painter_down(x) painter_right( y )
}

function painter_up( n ){
    return "\033[" n "A"
}

function painter_down( n ){
    return "\033[" n "B"
}

function painter_left( n ){
    return "\033[" n "D"
}

function painter_right( n ){
    return "\033[" n "C"
}
function painter_newline( n,        i, str ){
    for (i=1; i<=n; ++i){
        str = str "\r\n"
    }
    return str
}

function paint_screen( str ){
    # restore
    printf("%s", str) >"/dev/stderr"
    # restore
}

# Section: draw line

function painter_vline( x1, x2, y, color, c ){
    return painter_goto_rel( x1, y ) draw_vline( x2 - x1 + 1, c, color )
}

function painter_hline( x, y1, y2, color, r ){
    return painter_goto_rel( x, y1 ) draw_hline( y2 - y1 + 1, r, color )
}

function painter_vline_ends( x1, x2, y, color ){
    return painter_vline( x1+1, x2-1, y, color ) painter_goto_rel(x1, y) th(color, TH_BOX_HUP) painter_goto_rel(x2, y) th(color, TH_BOX_HDOWN)
}

function painter_hline_ends( x, y1, y2, color ){
    return painter_hline( x, y1+1, y2-1, color ) painter_goto_rel(x, y1) th(color, TH_BOX_VRIGHT) painter_goto_rel(x, y2) th(color, TH_BOX_VLEFT)
}

function painter_box_frame( x1, x2, y1, y2, color, c, r ){
    return \
    painter_vline( x1+1, x2-1, y1, color, c ) \
    painter_hline( x1, y1+1, y2-1, color, r ) \
    painter_vline( x1+1, x2-1, y2, color, c ) \
    painter_hline( x2, y1+1, y2-1, color, r )
}

function painter_box( x1, x2, y1, y2, color ){
    return painter_box_frame( x1, x2, y1, y2, color ) \
        draw_corner( x1, x2, y1, y2, color )
}

function painter_box_arc( x1, x2, y1, y2, color ){
    if (TH_BOX_STYLE == "BOLD") return painter_box( x1, x2, y1, y2, color )
    return painter_box_frame( x1, x2, y1, y2, color ) \
        draw_corner( x1, x2, y1, y2, color, "╭", "╮", "╰", "╯" )
}

function painter_clear_screen(x1,x2,y1,y2){
    # clear the data
    return painter_goto_rel(x1, y1) space_screen(x2-x1+1, y2-y1+1, "\r\n" painter_right( y1 ))
}

function painter_clear_allline(x1,x2){
    # clear the data
    return UI_CURSOR_RESTORE painter_down(x1) "\r" space_screen(x2-x1+1, COLS, "\r\n")
}

# EndSection
