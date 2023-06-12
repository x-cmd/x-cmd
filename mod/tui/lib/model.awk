
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

# Section: navi
function navi_arr_data_add_kv( o, kp, rootkp, viewdata, previewdata, preview_kp, viewlen,        l ){
    l = o[ kp, "data", rootkp L ] = o[ kp, "data", rootkp L ] + 1
    o[ kp, "data", rootkp, l, "view" ] = viewdata
    o[ kp, "data", rootkp, l, "preview" ] = previewdata
    o[ kp, "data", rootkp, l, "preview_kp" ] = preview_kp
    navi_arr_data_sel_add( o, kp, rootkp, viewdata)
    navi_arr_data_view_width(o, kp, rootkp, ((viewlen != "") ? int(viewlen) : 20))
}

function navi_arr_data_view_width( o, kp, rootkp, v,       l, m ){
    if (v == "")    return ( (l = o[ kp, "data", rootkp, "view.width" ]) > (m = navi_arr_data_maxview_width(o, kp)) ) ? m : l
    else            o[ kp, "data", rootkp, "view.width" ] = int(v)
}

function navi_arr_data_maxview_width( o, kp, v ){
    if (v == "")    return o[ kp, "maxview.width" ]
    else            o[ kp, "maxview.width" ] = int(v)
}

function navi_arr_data_preview_is_sel( o, kp, rootkp, idx ){
    return (navi_arr_data_preview( o, kp, rootkp, idx ) == "{")
}

function navi_arr_data_trace_col_val( o, kp, col, val, force_set ){
    if ((val == "") && (!force_set))  return o[ kp, "trace.col.rootkp", col ]
    else                              o[ kp, "trace.col.rootkp", col ] = val
}

function navi_arr_data_sel_add( o, kp, rootkp, val ){   model_arr_add( o, kp SUBSEP "comp.gsel" SUBSEP rootkp, val);     }
function navi_arr_data_sel_kp_get( kp, rootkp ) {       return kp SUBSEP "comp.gsel" SUBSEP rootkp;                      }
function navi_arr_data_len( o, kp, rootkp ) {           return o[ kp, "data", rootkp L ];                               }
function navi_arr_data_view( o, kp, rootkp, idx ){      return o[ kp, "data", rootkp, idx, "view" ];                    }
function navi_arr_data_preview( o, kp, rootkp, idx ){   return o[ kp, "data", rootkp, idx, "preview" ];                 }
function navi_arr_data_preview_kp( o, kp, rootkp, idx ){return o[ kp, "data", rootkp, idx, "preview_kp" ];              }

# EndSection

# Section: form
function form_arr_data_add(o, kp, var, desc, val,       l){
    model_arr_add(o, kp, var)
    l = model_arr_data_len(o, kp)
    model_arr_set_key_value(o, kp, l SUBSEP "desc",  desc)
    model_arr_set_key_value(o, kp, l SUBSEP "val", val)
    return l
}

function form_arr_get_data_len(o, kp){      return model_arr_data_len(o, kp);   }
function form_arr_get_data_var(o, kp, i){   return model_arr_data_get(o, kp, i);}
function form_arr_data_desc_width(o, kp, v){
    if (v == "")                    return model_arr_get(o, kp, "desc.width")
    return model_arr_set_key_value(o, kp, "desc.width",  v)
}
function form_arr_data_desc(o, kp, i, v, force_set){
    if ((v == "") && (!force_set))  return model_arr_get(o, kp, i SUBSEP "desc")
    return model_arr_set_key_value(o, kp, i SUBSEP "desc",  v)
}
function form_arr_data_val(o, kp, i, v, force_set){
    if ((v == "") && (!force_set))  return model_arr_get(o, kp, i SUBSEP "val")
    return model_arr_set_key_value(o, kp, i SUBSEP "val", v)
}

function form_arr_data_is_encrypted(o, kp, i, tf){
    if (tf == "")   return model_arr_get(o, kp, i SUBSEP "encrypted")
    return model_arr_set_key_value(o, kp, i SUBSEP "encrypted", tf)
}

function form_arr_data_is_match_rule(o, kp, i, v,       j, l){
    l = form_arr_data_rule_len(o, kp, i)
    for (j=1; j<=l; ++j){
        if (v ~ form_arr_data_rule_get(o, kp, i, j)) return true
    }
    return false
}
function form_arr_data_is_rule(o, kp, i){           return (form_arr_data_rule_len(o, kp, i) > 0); }
function form_arr_data_rule_len(o, kp, i){          return model_arr_data_len(o, kp SUBSEP i SUBSEP "rule"); }
function form_arr_data_rule_get(o, kp, i, j){       return model_arr_data_get(o, kp SUBSEP i SUBSEP "rule", j); }
function form_arr_data_rule_set_add(o, kp, i, v){   model_arr_add(o, kp SUBSEP i SUBSEP "rule", v); }
function form_arr_data_rule_set_arr(o, kp, i, arr,               j, l){
    l = arr[L]
    for (j=1; j<=l; ++j) model_arr_add(o, kp SUBSEP i SUBSEP "rule", arr[j])
}

function form_arr_data_is_select(o, kp, i){         return (form_arr_data_select_len(o, kp, i) > 0); }
function form_arr_data_select_len(o, kp, i){        return model_arr_data_len(o, kp SUBSEP i SUBSEP "comp.gsel");}
function form_arr_data_select_set_add(o, kp, i, v){ model_arr_add(o, kp SUBSEP i SUBSEP "comp.gsel", v);}
function form_arr_data_select_set_arr(o, kp, i, arr,               j, l){
    l = arr[L]
    for (j=1; j<=l; ++j) model_arr_add(o, kp SUBSEP i SUBSEP "comp.gsel", arr[j])
}

function form_arr_exit_strategy_len(o, kp){     return model_arr_data_len(o, kp SUBSEP "form.exit.strategy");}
function form_arr_exit_strategy_get(o, kp, i){  return model_arr_data_get(o, kp SUBSEP "form.exit.strategy", i);}
function form_arr_exit_strategy_set(o, kp, arr,         i, l){
    l = arr[L]
    for (i=1; i<=l; ++i) model_arr_add( o, kp SUBSEP "form.exit.strategy", arr[i])
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
