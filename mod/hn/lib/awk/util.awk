
function hn_value(v){
    return (v ~ "^\"") ? juq(v) : v
}

function hn_th( style, text, no_color ){
    if (no_color == true) return text
    return th( style, text )
}

function hn_preview(o, kp, item, no_color,          by, descendants, id, score, time, title, type, url, kids_num, parent, text, indent, _res){

    if ( item != "") {
        item = hn_th(UI_FG_YELLOW, sprintf("%4d", item) ". ", no_color)
        indent = "      "
    }

    if (o[ kp L ] <= 0) return item "null"
    else if (o[ kp, "\"deleted\"" ] == "true")  return item "deleted"
    else if (o[ kp, "\"dead\"" ] == "true")     return item "dead"

    by          = hn_value( o[ kp, "\"by\"" ] )
    # descendants = hn_value( o[ kp, "\"descendants\"" ] )
    id          = hn_value( o[ kp, "\"id\"" ] )
    score       = hn_value( o[ kp, "\"score\"" ] )
    title       = hn_value( o[ kp, "\"title\"" ] )
    # type        = hn_value( o[ kp, "\"type\"" ] )
    url         = hn_value( o[ kp, "\"url\"" ] )
    time        = hn_value( o[ kp, "\"time\"" ] )
    text        = hn_value( o[ kp, "\"text\"" ] )
    kids_num    = hn_value( o[ kp, "\"kids\"" L ] )
    parent      = hn_value( o[ kp, "\"parent\"" ] )


    score       = hn_th(UI_FG_GREEN, " " int(score) " point", no_color)
    by          = hn_th(UI_FG_YELLOW, " by " by, no_color)
    kids_num    = hn_th(UI_FG_GREEN, " | " int(kids_num) " comments", no_color)
    time        = hn_th(UI_FG_CYAN, " (" timestamp_to_date( time ) ")", no_color)
    _res        = item title
    _res        = _res "\n" indent score by time kids_num

    if (match( url, "://[^/]+" ) ) {
        _res    = _res "\n" indent hn_th(UI_FG_BRIGHT_BLACK, " link-url: " url, no_color)
    }

    _res = _res "\n" indent hn_th(UI_FG_BRIGHT_BLACK, " comment-url: https://news.ycombinator.com/item?id=" id, no_color)

    if ( parent != "" ) {
        _res = _res "\n" indent hn_th(UI_FG_BRIGHT_BLACK, " parent-url: https://news.ycombinator.com/item?id=" parent, no_color)
    }

    if ( text != "" ) {
        _res = _res "\n" indent hn_th(UI_FG_BRIGHT_BLACK, " text: " text, no_color)
    }

    return _res
}
