BEGIN{
    mount_data = ENVIRON[ "mount_data" ]
    l = split(mount_data, arr, "\n")
    for (i = 1; i <= l; i++) {
        split(arr[i], _arr, " ")
        gsub("(^\\(|\\)$)", "", _arr[6])
        mount_attr[ _arr[3] ] = _arr[6]
    }
    printf( "%s,%s,%s,%s,%s,%s,%s,%s\n", "Filesystem", "Type", "1K-blocks", "Used", "Available", "Use%", "Mounted_path", "Mounted_attr")
}

NR>1{
    attr = mount_attr[ $7 ]
    printf( "%s,%s,%s,%s,%s,%s,%s,%s\n",  $1, $2, $3, $4, $5, $6, $7, "\""attr"\"" )
}
