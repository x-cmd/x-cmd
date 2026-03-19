{ if ($0 != "") jiparse_after_tokenize(o, $0); }
END{
    model               = ENVIRON[ "model" ]
    # provider            = ENVIRON[ "provider" ]
    currency_unit       = ENVIRON[ "currency_unit" ]
    input_token         = int( ENVIRON[ "input_token" ] )
    input_cache_token   = int( ENVIRON[ "input_cache_token" ] )
    output_token        = int( ENVIRON[ "output_token" ] )
    KP_LLMP_DATA        = SUBSEP "\"1\""
    KP_CCY              = SUBSEP "\"2\""

    model_key = llmp_search_model( o, KP_LLMP_DATA, model )
    if ( model_key == "" ) {
        log_error("price", "Model["model"] not found")
        exit 1
    }

    totalprice  = llmp_total_calprice( o, KP_LLMP_DATA, model_key, input_token, input_cache_token, output_token)
    amount = llmp_usd_to_currency( o, KP_CCY, currency_unit, totalprice )
    if ( amount == "" ) {
        log_error("price", "Currency unit ["currency_unit"] not found")
        exit 1
    } else {
        print llmp_format_currency( amount, currency_unit )
    }
}
