BEGIN{
    printf("%s\n", "Search:")
}

{
    gsub("['\"`]", "\\&", $0)
    tmp         = substr( $0, 1, index($0, " - ")-1 )
    tmp_info    = substr( $0, index($0, " - ")+3 )
    gsub(/[ \r\t\b\v\n]+$/, "", tmp)

    if (existed[ tmp ] == 1)    next
    existed[ tmp ] = 1
    printf( "%s\n", tmp )
    arr_info[ ++item ] = tmp_info
}

END{
    printf( "%s\n", "---")
    for (i=1; i<=item; ++i)  printf( "%s\n", arr_info[i] )
    printf( "%s\n", "---" )
}
