BEGIN{
    PRINT_FMT = (format == "tsv") ? \
        "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" : \
        "%s,%s,%s,%s,%s,%s,%s,%s\n"

    mount_data = ENVIRON[ "mount_data" ]
    l = split(mount_data, arr, "\n")
    for (i = 1; i <= l; i++) {
        split(arr[i], _arr, " ")
        gsub("(^\\(|\\)$)", "", _arr[6])
        mount_attr[ _arr[3] ] = _arr[6]
    }
}

NR==1{
    printf( PRINT_FMT,  $1, $2, $3, $4, $5, $6, MOUNTED_PATH, MOUNTED_ATTR )
    next
}


{
    attr = mount_attr[ $7 ]
    printf( PRINT_FMT, $1, $2, $3, $4, $5, $6, $7, "\""attr"\"" )
}
