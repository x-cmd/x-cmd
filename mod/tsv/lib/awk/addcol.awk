{
    title = $0
    while (getline) {
        if ($0 ~ /===ADD-COL===/) {
            getline
            title = title "\t" $0
            break
        }
        data[ ++ datal ] = $0
    }

    while (getline) {
        ++ rowi
        data[ rowi ] = data[ rowi ] "\t" $0
    }

    print title
    for (i=1; i<=datal; ++i) print data[i]
}
