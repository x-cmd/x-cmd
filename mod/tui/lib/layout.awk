
function layout_avg_init( o, kp ){
    layout_avg_ele_clear( o, kp )
}

function layout_avg_ele_clear( o, kp ){
    o[ kp, "last.size" ] = 0
    o[ kp, "avg-layout" L ] = 0
    o[ kp, "left.col" ] = 1
    o[ kp, "right.col" ] = 1
}

function layout_avg_ele_add( o, kp, i, min, max ){
    l = o[ kp, "avg-layout" L ] = o[ kp, "avg-layout" L ] + 1
    o[ kp, "avg-layout", l ] = i
    o[ kp, "avg-layout", l, "min" ] = min
    o[ kp, "avg-layout", l, "max" ] = max

    o[ kp, "last.size" ] = 0        # Means it is changed.
}

function layout_avg_cal( o, kp, size, cur_col,       left_col, right_col, i, l, w, d ){
    left_col = o[ kp, "left.col" ]
    right_col = o[ kp, "right.col" ]
    if ((o[ kp, "last.size" ] == size) && (cur_col >= left_col) && (cur_col <= right_col)) return
    o[ kp, "last.size" ] = size

    if ( cur_col > right_col ) {
        o[ kp, "right.col" ] = right_col = cur_col
        for (i=right_col; i>=1; --i){
            w = o[ kp, "avg-layout", i, "min" ]
            if (size < w) break
            size -= w
            o[ kp, "avg-layout", i, "size" ] = w
        }
        left_col = o[ kp, "left.col" ] = i + 1
    } else {
        if ( cur_col < left_col ) o[ kp, "left.col" ] = left_col = cur_col
        l = o[ kp, "avg-layout" L ]
        for (i=left_col; i<=l; ++i) {
            w = o[ kp, "avg-layout", i, "min" ]
            if (size < w) break
            size -= w
            o[ kp, "avg-layout", i, "size" ] = w
        }
        right_col = o[ kp, "right.col" ] = i - 1
    }

    for (i=left_col; i<=right_col; ++i) {
        if (size<=0)   break
        d = o[ kp, "avg-layout", i, "max" ] - o[ kp, "avg-layout", i, "min" ]
        if (d <= 0) continue
        if (d > size) d = size
        size -= d
        o[ kp, "avg-layout", i, "size" ] += d
    }
    if (size>0) o[ kp, "avg-layout", --i, "size" ] += size
}

function layout_avg_get_item(o, kp, i){     return o[ kp, "avg-layout", i];     }
function layout_avg_get_size(o, kp, i){     return o[ kp, "avg-layout", i, "size" ];    }
function layout_avg_get_left_col(o, kp){    return o[ kp, "left.col" ];     }
function layout_avg_get_right_col(o, kp){   return o[ kp, "right.col" ];     }
function layout_avg_get_len(o, kp){     return o[ kp, "avg-layout" L ];     }
