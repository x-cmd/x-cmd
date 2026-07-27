BEGIN{
    PRINT_FMT = (format == "tsv") ? \
        "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" : \
        "%s,%s,%s,%s,%s,%s,%s,%s\n"

    in_df = 0
    header_printed = 0
}

in_df == 0 && $0 != separator {
    split($0, _arr, " ")
    gsub("(^\\(|\\)$)", "", _arr[6])
    mount_attr[ _arr[3] ] = _arr[6]
    next
}

$0 == separator {
    in_df = 1
    next
}

in_df == 1 && header_printed == 0 {
    printf( PRINT_FMT, $1, $2, $3, $4, $5, $6, MOUNTED_PATH, MOUNTED_ATTR )
    header_printed = 1
    next
}

{
    attr = mount_attr[ $7 ]
    printf( PRINT_FMT, $1, $2, $3, $4, $5, $6, $7, "\""attr"\"" )
}
