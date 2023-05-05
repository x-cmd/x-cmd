
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
function table_arr_init( o, kp ){           o[ kp, "data-arr" L ] = 0;  }
function table_arr_get_data(o, kp, i, j){   return o[ kp, "data-arr", "data", i, j ];   }
function table_arr_data_clear( o, kp ) {    return o[ kp, "data-arr", "data" L ] = 0;   }
function table_arr_is_available(o, kp, i){  return ( o[ kp, "data-arr", "data", i L ] > 0 );   }
function table_arr_available_count(o, kp){  return o[ kp, "data-arr", "data" L ];  }
function table_arr_data_add( o, kp, i, j, val ) {
    kp = kp SUBSEP "data-arr" SUBSEP "data"
    if ( o[ kp, i L ] == 0 ) o[ kp L ] = o[ kp L ] + 1
    o[ kp, i L ] = o[ kp, i L ] + 1
    o[ kp, i, j ] = val
}

function table_arr_head_len(o, kp){         return o[ kp, "data-arr", "head" L ]; }
function table_arr_head_get(o, kp, i){      return o[ kp, "data-arr", "head", i ]; }
function table_arr_head_add(o, kp, title,       l){
    kp = kp SUBSEP "data-arr" SUBSEP "head"
    o[ kp L ] = l = o[ kp L ] + 1
    o[ kp, l ] = title
    return l
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
