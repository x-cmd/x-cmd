($1 != "")&&(! arr[ "handled", $1 ]){
    arr[ "handled", $1 ] = 1
    w = length($1)
    if (w > maxw) maxw = w
    i = ++arr[ L ]
    arr[ i ] = $1
    $1 = ""
    arr[ i, "desc" ] = str_trim($0)
    arr[ i, "w" ] = w
}
END{
    str = "Commands:\n"
    l = arr[ L ]
    for (i=1; i<=l; ++i){
        str = str sprintf("  %-" maxw "s %s\n", arr[i], arr[i, "desc"])
    }

    str = str "\nOther inputs continue the loop, use \\ to start multi-line input content"
    print "\033[1;36m" str "\033[0m"
}
