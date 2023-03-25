
# Section: arr
function model_arr_init( o, kp ){
    kp = kp SUBSEP "data-arr"
    o[ kp L ] = 0
}

function model_arr_add( o, kp, val ) {
    kp = kp SUBSEP "data-arr"
    l = o[ kp, "data" L ] = o[ kp, "data" L ] + 1
    o[ kp, "data", l ] = val
}

function model_arr_rm( o, kp, val,      v, i, l ){
    kp = kp SUBSEP "data-arr"
    l = o[ kp, "data" L ]
    for (i=1; i<=l; ++i){
        v = o[ kp, "data", i ]
        if (v == val){
            delete o[ kp, "data", i ]
            for (o[ kp, "data" L ]=--l; i<=l; ++i) o[ kp, "data", i ] = o[ kp, "data", i+1 ]
            return true
        }
    }
    return false
}

function model_arr_data_get(o, kp, i) { return o[ kp, "data-arr", "data", i ];}
function model_arr_data_len(o, kp) { return int(o[ kp, "data-arr", "data" L ]); }
function model_arr_cp( o, kp, src, srckp, start, end,       i ) {
    kp = kp SUBSEP "data-arr"
    srckp = ((srckp!="") ? srckp SUBSEP : "")
    start = ((start!="") ? start : 1)
    end   = ((end!="") ? end : src[ srckp L ])

    for (i=start; i<=end; ++i) o[kp, "data",  i] = src[ srckp i ]
    o[ kp, "data" L ] += (end - start + 1)
}

function model_arr_clear( o, kp ) {
    kp = kp SUBSEP "data-arr"

    o[ kp, "data" L ] = 0
}

function model_arr_get(o, kp, idx){
    return o[ kp, "data-arr", idx ]
}


function model_arr_set_key_value(o, kp, key, val){
    kp = kp SUBSEP "data-arr"
    o[ kp SUBSEP key ] = val
}
# EndSection

# Section: table

function table_arr_init( o, kp ){
    kp = kp SUBSEP "data-arr"
    o[ kp L ] = 0
}

function table_arr_add( o, kp, i, j, val ) {
    kp = kp SUBSEP "data-arr"

    l = o[ kp, "data", i L ] = o[ kp, "data", i L ] + 1
    o[ kp, "data", i, j ] = val

    if (o[ kp, i, "ava" ] == "") {
        o[ kp, i, "ava" ] = 1
        o[ kp, "ava-row" ] += 1
    }
}

function table_arr_is_available(o, kp, i){  return ( o[ kp, "data-arr", i, "ava" ] == true );   }
function table_arr_available_row(o, kp){    return o[ kp, "data-arr", "ava-row" ];  }
function table_arr_get_data(o, kp, i, j){   return o[ kp, "data-arr", "data", i, j ];   }

function table_arr_cp( o, kp, src, srckp, start, end,       i, j, l ) {
    kp = kp SUBSEP "data-arr"

    for (i=start; i<=end; ++i) {
        l = o[kp, "data", i L]
        for (j=1; j<=l; ++j) o[kp, "data", i, j] = src[ srckp, i, j ]
        src[ srckp, i L]
    }
    src[ srckp, "ava-row" ] += (start - end + 1)
}

function table_arr_clear( o, kp ) {
    kp = kp SUBSEP "data-arr"
    o[ kp, "data" L ] = 0
}

# EndSection


function lock_acquire( o, kp ){
    if (o[ kp, "___LOCK" ]) return false
    o[ kp, "___LOCK" ] = true
    return true
}

function lock_release( o, kp ){
    if (o[ kp, "___LOCK" ] == false) return false
    o[ kp, "___LOCK" ] = false
    return true
}

function lock_unlocked( o, kp ){
    return o[ kp, "___LOCK" ] == false
}
