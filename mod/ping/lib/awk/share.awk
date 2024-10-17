
BEGIN {
    L = "\001"

    BLANK_80    = sprintf("\r%80s\r", "")
    BLANK_80_LN = "\033[0m" BLANK_80 "\n"
}


function float_lessthan( a, b ){
    # return (a < b)
    return ((a - b) < 0)
}

function printnl_fflush( char ){
    printf("%s", char);
    fflush()
}

function join_with_cleanup( arr,    i, l, _res ){
    l = arr[ L ]
    _res = ""
    for ( i=1; i<=l; ++l ) {
        _res = _res BLANK_80 line_dec_cleanup( arr[ i ] ) "\n"
    }
    return _res
}

function line_dec_cleanup( e ){
    return "\033[0m" BLANK_80 e "\n" "\033[0m"
}

BEGIN{
    if ( ( sytle_color == "256" ) || (sytle_color == "true") ) {
        STYLE_050 = "\033[38;5;46m";           # green
        STYLE_100 = "\033[38;5;41m";           # green
        STYLE_150 = "\033[38;5;51m";           # cyan
        STYLE_200 = "\033[38;5;14m";           # blue
        STYLE_300 = "\033[38;5;226m";          # yellow
        STYLE_500 = "\033[38;5;200m";          # magenta
        STYLE_XXX = "\033[38;5;196m";          # red

        STYLE_ERR = "\033[38;5;196m"
    } else {
        STYLE_050 = "\033[32m";          # green
        STYLE_100 = "\033[32m";          # green
        STYLE_150 = "\033[36m";          # cyan
        STYLE_200 = "\033[34m";          # blue
        STYLE_300 = "\033[33m";          # yellow
        STYLE_500 = "\033[35m";          # magenta
        STYLE_XXX = "\033[31m";          # red

        STYLE_ERR = "\033[31m"
    }
}

function colrmap( time ){
    if ( time == -1 )                   return STYLE_ERR
    if ( float_lessthan(time, 50  ) )   return STYLE_050;
    if ( float_lessthan(time, 100 ) )   return STYLE_100;
    if ( float_lessthan(time, 150 ) )   return STYLE_150;
    if ( float_lessthan(time, 200 ) )   return STYLE_200;
    if ( float_lessthan(time, 300 ) )   return STYLE_300;
    if ( float_lessthan(time, 500 ) )   return STYLE_500;
                                        return STYLE_XXX;
}

function colrmapstr( time, str ) {
    return colrmap(time) str "\033[0m"
}

function barmap( time ){
    if (time == -1)                     return "X"
    if (float_lessthan( time,   50 ) )  return "▁" ;       # green
    if (float_lessthan( time,  100 ) )  return "▂" ;       # green
    if (float_lessthan( time,  150 ) )  return "▃" ;       # blue
    if (float_lessthan( time,  200 ) )  return "▅" ;       # yellow
    if (float_lessthan( time,  300 ) )  return "▆" ;       # yellow
    if (float_lessthan( time,  500 ) )  return "▇" ;       # red
                                        return "█"         # red
}

function barmap2( time ){
    if (time == -1)                     return "X"
    if (float_lessthan( time,   50 ) )  return "█" ;       # green
    if (float_lessthan( time,  100 ) )  return "▇" ;       # green
    if (float_lessthan( time,  150 ) )  return "▆" ;       # blue
    if (float_lessthan( time,  200 ) )  return "▅" ;       # yellow
    if (float_lessthan( time,  300 ) )  return "▃" ;       # yellow
    if (float_lessthan( time,  500 ) )  return "▂" ;       # red
                                        return "▁"         # red

}

BEGIN{
    INDENT_SPACE = "      "
}
