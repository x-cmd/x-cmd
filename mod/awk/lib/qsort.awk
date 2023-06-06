
# ___qsort_a_tmp declare global so it could be faster
function qsort2(arr, start, end,  i,j,k){
    if (start>=end) return
    i = start-1
    j = end+1
    s = arr[ int( (i + j) / 2 ) ]
    for (k=start; k<=end; ++k) {
        e = arr[k]
        if (e==s)   continue
        if (e < s)  ___qsort_a_tmp[++i] = e
        else        ___qsort_a_tmp[--j] = e
    }

    for (k=i+1; k<j; ++k) ___qsort_a_tmp[k] = s
    for (k=start; k<=end; ++k) arr[k] = ___qsort_a_tmp[k]

    qsort2(arr, start, i)
    qsort2(arr, j, end)
}

function qsort(arr, start, end,  i,j,k,s,t){
    if (start>=end) return
    i = start-1
    j = end+1

    s = arr[ int( (i + j) / 2 ) ]
    while (i<j) {
        while (arr[++i] < s) { }
        while (arr[--j] > s) { }
        if (i < j) {
            t = arr[i]
            arr[i] = arr[j]
            arr[j] = t
        }
    }

    qsort(arr, start, j)
    qsort(arr, j+1, end)
}

function arr_qsort( arr ){
    qsort(arr, 1, arr[ L ])
}

function arr_qsort_uniq( arr ){
    qsort(arr, 1, arr[ L ])
    arr_uniq( arr )
}


# function test( o ){
#     for (i=1; i<=20; ++i) {
#         arr_push( o, int((32 * i ) % 17))
#     }

#     print o[L] " " arr_join( o, " " )
#     arr_qsort_uniq( o )
#     print o[L] " " arr_join( o, " " )

# }

# BEGIN {

#     test()
# }



# function randarr(arr, l, i){
#     for (i=1; i<=l; ++i) {
#         arr[i] = int(rand() * 100)
#     }
# }

# function checkarr(arr, l, i){
#     for (i=2; i<=l; ++i) {
#         if (arr[i-1] > arr[i] ) return 0
#     }
#     return 1
# }

# function test(){
#     time = 1000
#     len = 1000
#     for (i=1; i<=time; ++i) {
#         randarr(arr, len)
#         qsort(arr, 1, len)
#         # parr(arr)
#         if (0 == checkarr(arr, len) ) print "Wrong"
#         # parr
#     }
# }


# function parr(arr, i){
#     for (i=1; i<=length(arr); ++i) {
#         printf("%s ", arr[i])
#     }
#     print
# }

# END{
#     # arr[1]=8
#     # arr[2]=5
#     # arr[3]=5
#     # arr[4]=11
#     # arr[5]=5
#     # arr[6]=1
#     arr[1]=5
#     arr[2]=5
#     arr[3]=5
#     # arr[4]=5
#     # arr[5]=5
#     # arr[6]=5
#     # arr[7]=5
#     # arr[8]=5
#     qsort(arr, 1, length(arr))
#     parr(arr)

#     # test()
# }
