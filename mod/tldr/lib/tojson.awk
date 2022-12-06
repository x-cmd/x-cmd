
# Section: utils
# From xrc awk/lib/str
function str_trim(astr){
    gsub(/^[ \t\b\v\n]+/, "", astr)
    gsub(/[ \t\b\v\n]+$/, "", astr)
    return astr
}

function str_quote2(str){
    gsub(/\\/, "\\\\", str)
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}
# EndSections

BEGIN{
    print "{"

    body = ""
}

function kv(key, value,         _ret){
    _ret = key
    _ret = _ret "\n:"
    _ret = _ret "\n" value
    return _ret
}

{
    $0 = str_trim( $0 )

    if ($0 ~ /^[ \t\r]*$/){

    } else if ($1~/^#/)
    {
        gsub(/^#[ ]*/, "", $0)
        print "\"t\""
        print ":"
        print str_quote2( $0 )
    } else if ($1~/^>/) {
        gsub(/^>[ ]*/, "", $0)
        desc = desc ( (desc == "") ? "" : "\\n" ) $0
    } else if ($1 ~ /^-/) {
        gsub(/^-[ ]*/, "", $0)
        cmd_info = $0
    } else {
        if ($0 !~ /^`[^`]+`/)  next

        body = body ( (body == "") ? "" : "\n,\n" )
        body = body "{"

        body = body "\n" kv( "\"d\"", str_quote2( cmd_info ) )
        body = body "\n,"
        body = body "\n" kv( "\"c\"", str_quote2( substr($0, 2, length($0)-2) ) )

        body = body "\n}"
    }
}

END{
    print ","
    print kv( "\"d\"", str_quote2( desc ) )
    print ","
    print kv( "\"b\"", "[\n" body "\n]")
    print "}"
}
