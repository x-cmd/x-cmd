function paint_rectangular( x1, y1, x2, y2 ){
    paint_line_vertical( x1+1, x2-1, y1 )
    paint_line_vertical( x1+1, x2-1, y2 )

    paint_line_horizontal( x1, y1+1, y2-1 )
    paint_line_horizontal( x2, y1+1, y2-1 )

    paint_char( x1, y1, "┌")
    paint_char( x1, y2, "┐")
    paint_char( x2, y1, "└")
    paint_char( x1, y2, "┘")
}


function paint_line_vertical( x1, x2, y, char ){
    if (char == "") char = "│"
    cursor_goto(x1, y)
    for (i=x1; i<=x2; ++i) printf("%s", char ui_cursor_movedown(1))
}

function paint_line_horizontal( x, y1, y2, char ){
    if (char == "") char = "─"
    cursor_goto(x, y1)
    for (i=y1; i<=y2; ++i) printf("%s", char)
}
