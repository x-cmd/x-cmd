
function layout_avg_init( o, kp ){
    layout_avg_ele_clear( o, kp )
}

function layout_avg_ele_clear( o, kp ){
    o[ kp, "last.size" ] = 0
    o[ kp, "avg-layout" L ] = 0
}

function layout_avg_ele_add( o, kp, i, min, max ){
    l = o[ kp, "avg-layout" L ] = o[ kp, "avg-layout" L ] + 1
    o[ kp, "avg-layout", l ] = i
    o[ kp, "avg-layout", l, "min" ] = min
    o[ kp, "avg-layout", l, "max" ] = max

    o[ kp, "last.size" ] = 0        # Means it is changed.
}

function layout_avg_cal( o, kp, size,       i, l, w, d ){
    if (o[ kp, "last.size" ] == size) return
    o[ kp, "last.size" ] = size

    l = o[ kp, "avg-layout" L ]
    for (i=1; i<=l; ++i) {
        w = o[ kp, "avg-layout", i, "min" ]
        o[ kp, "avg-layout", i ] = o[ kp, "avg-layout", i ]
        if (size < w) break
        size -= w
        o[ kp, "avg-layout", i, "size" ] = w
    }

    l = o[ kp, "avg-layout" L ] = --i
    for (i=1; i<=l; ++i) {
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
function layout_avg_get_len(o, kp){     return o[ kp, "avg-layout" L ];     }
