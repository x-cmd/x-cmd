
# This is the awk code
function lolcat( str_arr, start, step, end,    i ){

    for( i = start; i <= end; i += step ){
        print str_arr[i]
    }
}

