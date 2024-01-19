
# [:alnum:]
# [:alpha:]
# [:space:]
# [:blank:]
# [:upper:]
# [:lower:]
# [:digit:] [0-9]
# [:xdigit:]
# [:punct:]
# [:cntrl:]
# [:graph:]
# [:print:]

# - to reprenset a ch in bracket must be the last ch

function re( p0, ch ){              return "(" p0 ")" ch;   }
function re_match( str, regex ){    return match( str, re_patgen( regex ) ); }
function re_patgen( regex,  t ){    return ((t = RE_PAT_CACHE[ regex ]) != "") ? t : (RE_PAT_CACHE[ regex ] = re_patgen___( regex )); }

function re___pat_gsub( srcpat, tgtpat, regex ){
    if ( srcpat == regex ){
        return tgtpat
    }
    return regex
}

function re_patname( name ){    return "[:" name ":]";  }
function re_patgen___( regex,  _tmp, _tmp_arr ){

    regex = re___pat_gsub( re_patname( "int" ),       RE_NUMBER,             regex )
    regex = re___pat_gsub( re_patname( "real" ),      RE_NUM,                regex )
    regex = re___pat_gsub( re_patname( "qu" ),        RE_STR2,               regex )
    regex = re___pat_gsub( re_patname( "qu1" ),       RE_STR1,               regex )
    regex = re___pat_gsub( re_patname( "float" ),     RE_FLOAT,              regex )
    regex = re___pat_gsub( re_patname( "ip-a" ),      RE_IP_A,               regex )
    regex = re___pat_gsub( re_patname( "ip-b" ),      RE_IP_B,               regex )
    regex = re___pat_gsub( re_patname( "ip-c" ),      RE_IP_C,               regex )
    regex = re___pat_gsub( re_patname( "ip-d" ),      RE_IP_D,               regex )
    regex = re___pat_gsub( re_patname( "ip-E" ),      RE_IP_E,               regex )
    regex = re___pat_gsub( re_patname( "ip" ),        RE_IP,                 regex )
    # regex = re___pat_gsub( re_patname( "ipv6" ),       "",                 regex )
    regex = re___pat_gsub( re_patname( "url" ),       RE_URL,                regex )
    regex = re___pat_gsub( re_patname( "http" ),      RE_URL_HTTP,           regex )
    regex = re___pat_gsub( re_patname( "https" ),     RE_URL_HTTPS,          regex )
    regex = re___pat_gsub( re_patname( "httpx" ),     RE_URL_HTTPX,          regex )

    if (match(regex, /\[:([0-9])+-([0-9])+:\]/)) {
        _tmp = substr(regex, RSTART, RLENGTH)
        split(_tmp, _tmp_arr, "-")
        regex = re___pat_gsub( re_patname( _tmp_arr[1] "-" _tmp_arr[2] ), re_range( _tmp_arr[1], _tmp_arr[2] ), regex)
    }

    return regex
}

BEGIN{
    RE_INTERVAL_EXPRESSIONS_SUPPORTED = ("XXXX" ~ /^X{0,4}$/)
    RE_OR = "|"

    RE_SPACE = "[ \t\v\n]+"

    RE_NUMBER = "^[-+]?[0-9]+$"
    RE_NUM = "[-+]?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?"
    RE_NUM_PERCENTAGE = "(0|[1-9][0-9]*)([.][0-9]+)?%"
    RE_REDUNDANT = "([ \t]*[\n]+)+"

    # RE_TRIM = re_or( "^" RE_SPACE, RE_SPACE "$" )
    RE_TRIM = "^" RE_SPACE RE_OR RE_SPACE "$"

    # RE_TRIM = re_or( "^[\n]+", "[\n]+$" )
}

BEGIN {
    RE_EMAIL = "[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)+"    # Check this out ...
    RE_DIGIT = "[0-9]"      # [:digit:]
    RE_DIGITS = "[0-9]+"    # [:digit:]+

    RE_INT = "[+-]?([1-9][0-9]*)|0"
    RE_INT0 = "[+-]?[0-9]+"
    RE_FLOAT = "(-?[1-9][0-9]*.[0-9]+$|^-?0.[0-9]+$|^-?[1-9][0-9]*$|^0)"

    RE_UTF8_HAN = "[一-龥]+"
    RE_UTF8_NON_ASCII = "[^\0-\127]+$"

    RE_033 = "\033\\[[^A-Za-z]*[A-Za-z=]"

    RE_IP_A = re_range(0, 127)   re_interval_expression( "([.]" re_range(0, 255) ")", 3 )
    RE_IP_B = re_range(128, 191) re_interval_expression( "([.]" re_range(0, 255) ")", 3 )
    RE_IP_C = re_range(192, 223) re_interval_expression( "([.]" re_range(0, 255) ")", 3 )
    RE_IP_D = re_range(224, 239) re_interval_expression( "([.]" re_range(0, 255) ")", 3 )
    RE_IP_E = re_range(240, 247) re_interval_expression( "([.]" re_range(0, 255) ")", 3 )
    RE_IP   =   re_range(0, 255) re_interval_expression( "([.]" re_range(0, 255) ")", 3 )

    RE_IP_SUBNET = ""

    RE_URL_BODY = "[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[.]" re_interval_expression( "[a-z]", 2, 6 ) "(/[-A-Za-z0-9+&@#/%?=~_|]*)?"

    RE_URL          =   "([a-zA-Z0-9]+://)?" RE_URL_BODY
    RE_URL_HTTP     =   "(http)://"          RE_URL_BODY
    RE_URL_HTTPX    =   "(httpS?)://"        RE_URL_BODY
    RE_URL_HTTPS    =   "(https)://"         RE_URL_BODY
}

BEGIN{
    # /"[^"\\\001-\037]*((\\[^u\001-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\001-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./
    # RE_STR2_ORGINAL = "\"[^\"\\\\\001-\037]*((\\\\[^u\001-\037]|\\\\u[0-9a-fA-F]{4})[^\"\\\\\001-\037]*)*\""

    RE_QUOTE_CONTROL_OR_UNICODE = re( "\\\\[^u\001-\037]" RE_OR "\\\\u" re_interval_expression( "[0-9a-fA-F]", 4 ) )

    RE_NOQUOTE1 = "[^'\\\\\001-\037]*"
    RE_STR1 = "'"  RE_NOQUOTE1 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE1, "*")  "'"

    RE_NOQUOTE2 = "[^\"\\\\\001-\037]*"
    RE_STR2 = "\"" RE_NOQUOTE2 re( RE_QUOTE_CONTROL_OR_UNICODE RE_NOQUOTE2, "*" ) "\""

    # RE_STR0 = "[^ \\t\\v\\n]*" "((\\\\[ ])[^ \\t\\v\\n]*)*"
    RE_STR0 = "(\\\\[ ])*[^ \t\v\n]+"  "((\\\\[ ])[^ \t\v\n]*)*"
}

# awk 'BEGIN{ match("-b+cd", "[[:alnum:][:punct:]]*"); print RLENGTH " " RSTART; }'

# Section: range
function re_range2pattern_all_digit( num, digit ){
    gsub(/[0-9]/, digit, num)
    return num
}

function re_range( start, end,      i, _startl, _endl, _res, _num9 ){
    _startl = length( start )
    _endl   = length( end )

    if (_startl == _endl)   return re_range2pattern( start, end )

    _num9   = re_range2pattern_all_digit( start, 9 )
    _num0   = 1 substr(re_range2pattern_all_digit( _num9, 0 ), 2)

    _res    = re_range2pattern_main( start, _num9 )

    for (i=_startl+1; i<_endl; ++i) {
        _res = _res "|" re_range2pattern_main( ( _num0 = _num0 "0" ), ( _num9 = _num9 "9" ) )
    }

    _res = _res "|" re_range2pattern_main( ( _num0 = _num0 "0" ), end )

    return "(" _res ")"
}

function re_range2pattern_main( start, end ){
    # print start, end
    return re_range2pattern(start, end)
}

# 1-13 = [1-9]
# 11-13 = 1[1-3]
# 128-192=[1](2[8-9])|([3-8])
function re_range2pattern( start, end,      l, _res, _rest_0, _rest_9, _start_a, _start_rest, _end_a, _end_rest, _mid_start, _mid_end ){
    l = length( start )
    if (l == 1)       return (start == end) ? start : sprintf("[%s-%s]", start, end)
    _start_a        = substr(start, 1, 1)
    _start_rest     = substr(start, 2, l-1)
    _end_a          = substr(end, 1, 1)
    _end_rest       = substr(end, 2, l-1)

    _rest_0         = re_range2pattern_all_digit( _start_rest, 0 )
    _rest_9         = re_range2pattern_all_digit( _start_rest, 9 )

    if (_start_a == _end_a) {
        return _start_a re_range2pattern( _start_rest, _end_rest )
    }

    _mid_start      = _start_a + 1
    _mid_end        = _end_a - 1

    _res = ""
    if (_start_rest == 0)       _mid_start -= 1
    else                        _res =  ((_res == "") ? "" : _res "|")  sprintf("(%s)", _start_a    re_range2pattern( _start_rest, _rest_9  ) )

    if ( _end_rest == _rest_9 ) _mid_end += 1
    else                        _res =  ((_res == "") ? "" : _res "|")  sprintf("(%s)", _end_a      re_range2pattern( _rest_0, _end_rest  ) )

    if (_mid_start == _mid_end) _res =  ((_res == "") ? "" : _res "|")  ( (l==2) ?  sprintf("(%s[0-9])",       _mid_start)          : sprintf("(%s%s)",      _mid_start, re_interval_expression("[0-9]", l-1)) )
    if (_mid_start <  _mid_end) _res =  ((_res == "") ? "" : _res "|")  ( (l==2) ?  sprintf("([%s-%s][0-9])",  _mid_start, _mid_end) : sprintf("([%s-%s]%s)", _mid_start, _mid_end, re_interval_expression("[0-9]", l-1)) )
    return "(" _res ")"
}

function re_wmatch( val, regex ){
    return match( val, "^" regex "$" )
}

function re_interval_expression( r, n, m,       i, s ){
    if( RE_INTERVAL_EXPRESSIONS_SUPPORTED ) {
        if ( m == "" ) return "(" r "{" n "})"
        return "(" r "{" n "," m "})"
    }

    if ( m == "" ) return re_interval_expression_( r, n )
    for (i=m; i>=n; --i) s = ((s != "") ? s "|" : "") re_interval_expression_( r, i )
    return "(" s ")"
}

function re_interval_expression_( r, n,     i, s ) {
    for (i=1; i<=n; ++i) s = s r
    return "(" s ")"
}

BEGIN{
    RE_C0 = "[\001-\020]"
    RE_NON_C0 = "[^\001-\020]"

    # wrong: LC_ALL=C awk 'BEGIN{ RE_C_PRINTABLE = "[^\x01-\x08\x0B\x0C\x0E\x0F\x7F]"; } $0~"^"RE_C_PRINTABLE"$"{ print $0; }' <<<"均"
    # true:  LC_ALL=en_US.UTF-8 awk 'BEGIN{ RE_C_PRINTABLE = "[^\x01-\x08\x0B\x0C\x0E\x0F\x7F]"; } $0~"^"RE_C_PRINTABLE"$"{ print $0; }' <<<"均"
    RE_C_PRINTABLE = "[^\x01-\x08\x0B\x0C\x0E\x0F\x7F]" # Unfinish

    RE_NB_JSON_CONTENT_NEG = "\x00-\x08\x0A-\x19"
    RE_NB_JSON = "[^" RE_NB_JSON_CONTENT_NEG "]"                # x09 | [x20-x10FFFF]

    RE_B_CHAR = "[\x0A\x0D]"
    RE_B_BREAK = "((\x0A\x0D)|[\x0A\x0D])"              # B_AS_LINE_FEED

    RE_NB_CHAR = "[^\x01-\x08\x0A-\x0F\x7F]"            # Except for \xFEFF

    RE_S_WHITE = "[\x09\x20]"
    RE_NS_CHAR = "[^\x01-\x0F\x20\x7F]"

    RE_NS_DEC_DIGIT = "[0-9]"
    RE_NS_HEX_DIGIT = "[0-9A-Fa-f]"
    RE_NS_WORD_CHAR = "[0-9A-Za-z-]"

    # RE_NS_URI_CHAR = "(%[0-9A-Fa-f]{2})|" RE_NS_WORD_CHAR "|[#;/?:@&=+$,_.!~*'\\(\\)\\[\\]]"
    RE_NS_URI_CHAR = "(%" re_interval_expression(RE_NS_HEX_DIGIT, 2) ")|" RE_NS_WORD_CHAR "|[#;/?:@&=+$,_.!~*'\\(\\)\\[\\]]"
    RE_NS_TAG_CHAR = "(%" re_interval_expression(RE_NS_HEX_DIGIT, 2) ")|" RE_NS_WORD_CHAR "|[#;/?:@&=+$_.~*']"

    RE_NB_SINGLE_QUOTED_CHAR = "(('')|[^" RE_NB_JSON_CONTENT_NEG "'])"
    RE_NB_SINGLE_QUOTED_STR = "('" RE_NB_SINGLE_QUOTED_CHAR "')"

}
