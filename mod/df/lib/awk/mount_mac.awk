BEGIN{
    PRINT_FMT = (format == "tsv") ? \
        "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" : \
        "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\"%s\"\n"

    mount_data = ENVIRON[ "mount_data" ]
    l = split(mount_data, mount, "\n")
    for (i = 1; i <= l; i++) {
        split(mount[i], arr, " on ")
        split(arr[2], _arr, " \\(")
        gsub("\\)$", "", _arr[2])
        mount_attr[ _arr[1] ] =  _arr[2]
    }
}

NR==1{
    t = index($0, "Type")
    printf( PRINT_FMT,  $1, $2, $3, $4, $5, $6, $7, $8, $9, MOUNTED_PATH, MOUNTED_ATTR )
    next
}

{
    first = substr($0, 1, t-1)
    gsub("(^[ ]+)|([ ]+$)", "", first)
    $0 = substr($0, t)

    attr = mount_attr[ $9 ]
    printf( PRINT_FMT,  first, $1, $2, $3, $4, $5, $6, $7, $8, $9, attr )
}
