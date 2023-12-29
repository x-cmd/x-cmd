( NR==1 ) && ($0 ~ "^{"){
    IS_ERROR_CONTENT=1
    jiparse_after_tokenize( o_error, $0 )
}
( $0 ~ "event:"){
    event = substr($0, 7)
    if (event != "finish") IS_ERROR_CONTENT = 1
    next
}
( $0 ~ "^data:" ){
    data = substr($0, 6)
    if (last_data_row == NR - 1) data = "\n" data
    last_data_row = NR
    printf ( last_data = data )
    fflush()
    next
}
( $0 ~ "^meta:" ){
    meta = substr($0, 6)
    next
}

function zhipu_display_response_text_end(){
    if (IS_ERROR_CONTENT != 1) printf "\n"
    else {
        print log_error("zhipu", log_mul_msg(jstr(o_error)))
    }
}

END{
    zhipu_display_response_text_end()
}

