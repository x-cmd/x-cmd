
# TODO: in the future ... seconds: 0:111:888:86400=1.3:3.4:31
function llmp_search_model(llmp_obj, llmp_kp, model){
    model = ( model ~ "^\"" ) ? model : jqu(model)
    if ( jdict_has( llmp_obj, llmp_kp, model ) ) {
        return model
    }

    model = juq(model)
    if ((v = llmp_search_model___inner( llmp_obj, llmp_kp, model )) != "" ) return v

    if ( match(model, "-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$") ){
        model = substr(model, 1, RSTART -1)
        return llmp_search_model___inner( llmp_obj, llmp_kp, model )
    }
}

function llmp_search_model___inner( llmp_obj, llmp_kp, model,       i, l, key ){
    sub( ".*/", "", model )
    l = llmp_obj[ llmp_kp L ]
    for (i=1; i<=l; ++i){
        key = juq(llmp_obj[ llmp_kp, i ])
        if ( key ~ "(^|/)" model "$" ) return jqu(key)
    }
}

function llmp_input_get( vendor_model, key ){

}

# TODO: use count and day_second
function llmp_input_unitprice_text( llmp_obj, llmp_kp, vendor_model,         count, day_second ){
    return llmp_obj[ llmp_kp, vendor_model, "\"input\"", "\"text\"" ] / (1000000)
}

function llmp_input_unitprice_text_cache( llmp_obj, llmp_kp, vendor_model,   count, day_second  ){
    return llmp_obj[ llmp_kp, vendor_model, "\"input\"", "\"text-cache\"" ] / (1000000)
}

function llmp_input_calprice( llmp_obj, llmp_kp, vendor_model, input_count, cache_count, day_second,      a, b ){
    # stage ...

    a = llmp_input_unitprice_text(        llmp_obj, llmp_kp, vendor_model, input_count, day_second ) * input_count
    b = llmp_input_unitprice_text_cache(  llmp_obj, llmp_kp, vendor_model, input_count, day_second ) * cache_count
    return a + b
}

function llmp_output_get( vendor_model, key ){

}

function llmp_output_unitprice_text( llmp_obj, llmp_kp, vendor_model, count, day_second ){
    return llmp_obj[ llmp_kp, vendor_model, "\"output\"", "\"text\"" ] / (1000000)
}

function llmp_output_calprice( llmp_obj, llmp_kp, vendor_model, output_count, day_second ){
    return llmp_output_unitprice_text( llmp_obj, llmp_kp, vendor_model, output_count, day_second ) * output_count
}

function llmp_total_calprice( llmp_obj, llmp_kp, vendor_model, input_count, input_cache_count, output_count, day_second ){
    a = llmp_input_calprice(    llmp_obj, llmp_kp, vendor_model, input_count, input_cache_count, day_second )
    b = llmp_output_calprice(   llmp_obj, llmp_kp, vendor_model, output_count, day_second)
    return a + b
}

function llmp_amount_calccy( ccy_obj, ccy_kp, ccy, price ){
    ccy = ( ccy ~ "^\"" ) ? ccy : jqu(ccy)
    if ( ccy == "\"USD\"" ) return price
    if ( ! jdict_has( ccy_obj, ccy_kp, ccy ) ) return
    return price * ccy_obj[ ccy_kp, ccy ]
}

function llmp_format_ccy( amount, ccy,          v ){
    if ( ccy == "USD" ) {
        v = sprintf( "$%.6f", amount )
    } else if ( ccy == "RMB" ) {
        v = sprintf( "¥%.6f", amount )
    } else if ( ccy == "EUR" ) {
        v = sprintf( "€%.6f", amount )
    }

    return v
}
