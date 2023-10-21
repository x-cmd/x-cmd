BEGIN{
    IFS="\t"

    # Give a name
}

function handle(        _id, _hex, _rgb, _rgba, _hsl, _hsla, _name, _name0 ){
    _id = $1
    _hex = hex[ _id ] = substr($2, 2)

    _rgb = $3;   split(_rgb, _rgba, ",")
    _hsl = $4;   split(_hsl, _hsla, ",")

    name[ _id ]     = _name     = $5;
    name0[ _id ]    = _name0    = tolower(_name)

    hex[ _id ]  = colr[ _id, "hex" ]    = _hex
    rgb[ _id ]  = colr[ _id, "rgb" ]    = _rgb
    hsl[ _id ]  = colr[ _id, "hsl" ]    = _hsl

    r[ _id ]    = colr[ _id, "r" ]      = _rgba[1]
    g[ _id ]    = colr[ _id, "g" ]      = _rgba[2]
    b[ _id ]    = colr[ _id, "b" ]      = _rgba[3]

    h[ _id ]    = colr[ _id, "h" ]      = _hsla[3]
    s[ _id ]    = colr[ _id, "s" ]      = _hsla[3]
    l[ _id ]    = colr[ _id, "l" ]      = _hsla[3]
}

{
    handle()
}

BEGIN{
    UI_RESET = "\033[0m"
}

function pcolorline( i ){
    COLRSET = "\033[48;5;" i "m"
    printf("%s", COLRSET)
    printf("%5s", i)
    printf("%s", "  ")
    printf("%s", UI_RESET)

    printf("%s", "  ")

    RGBSET = "\033[48;2;" r[i] ";" g[i] ";" b[i] "m"
    printf("%s", RGBSET)
    printf("%20s", rgb[i])
    printf("  %s  ", UI_RESET)

    printf("%s", RGBSET)
    printf("%20s", name[i])
    printf("%s", UI_RESET)
}

