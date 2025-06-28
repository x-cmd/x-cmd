
# Prepare data ...
$2~/[-]1[-]1$/{
    gsub(/-[^$]+$/, "", $2)
    split($1, arr, "[-/]")
    y = arr[1]

    val[y] = arr[2] * 100 + arr[3]
}

END{
    arrl = split(ENVIRON["DATA"], arr, " ")
    for (i=1; i<=arrl; ++i) {
        split(arr[i], a, "[-/]")
        print( lunar_get_shengxiao_zh( ((a[2] * 100 + a[3]) >= val[a[1]]) ? a[1] : (a[1]-1) ) )
    }
}
