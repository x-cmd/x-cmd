BEGIN{
    TH_BOX_STYLE = ENVIRON[ "___X_CMD_TUI_TH_BOX_STYLE" ]
    if (TH_BOX_STYLE == "") TH_BOX_STYLE = "THIN" # "BOLD"
    TH_BOX_VLINE        = (TH_BOX_STYLE == "BOLD") ? "┃" : "│"
    TH_BOX_HLINE        = (TH_BOX_STYLE == "BOLD") ? "━" : "─"
    TH_BOX_UP_LEFT      = (TH_BOX_STYLE == "BOLD") ? "┏" : "┌"
    TH_BOX_UP_RIGHT     = (TH_BOX_STYLE == "BOLD") ? "┓" : "┐"
    TH_BOX_DOWN_LEFT    = (TH_BOX_STYLE == "BOLD") ? "┗" : "└"
    TH_BOX_DOWN_RIGHT   = (TH_BOX_STYLE == "BOLD") ? "┛" : "┘"
    TH_BOX_VRIGHT       = (TH_BOX_STYLE == "BOLD") ? "┣" : "├"
    TH_BOX_VLEFT        = (TH_BOX_STYLE == "BOLD") ? "┫" : "┤"
    TH_BOX_HUP          = (TH_BOX_STYLE == "BOLD") ? "┳" : "┬"
    TH_BOX_HDOWN        = (TH_BOX_STYLE == "BOLD") ? "┻" : "┴"
}

function draw_vline( l, c, color,    i, s ){
    s = c = ((c) ? c : TH_BOX_VLINE) "\033[1D"
    for (i=2; i<=l; ++i) s = s "\033[1B" c
    return th( color, s )
}

function draw_hline( l, c, color,     i, s ){
    s = c = ((c) ? c : TH_BOX_HLINE)
    for (i=2; i<=l; ++i) s = s c
    return th( color, s )
}

function draw_corner( x1, x2, y1, y2, color,        ul, ur, dl, dr ) {
    ul = ((ul) ? ul : TH_BOX_UP_LEFT)
    ur = ((ur) ? ur : TH_BOX_UP_RIGHT)
    dl = ((dl) ? dl : TH_BOX_DOWN_LEFT)
    dr = ((dr) ? dr : TH_BOX_DOWN_RIGHT)

    return  painter_goto_rel(x1, y1) th(color, ul) \
            painter_goto_rel(x2, y1) th(color, dl) \
            painter_goto_rel(x1, y2) th(color, ur) \
            painter_goto_rel(x2, y2) th(color, dr)
}

function draw_text_first_line( s,     i ){
    if ( (i = index(s, "\n")) <=0 ) return s
    return substr( s, 1, i-1 )
}