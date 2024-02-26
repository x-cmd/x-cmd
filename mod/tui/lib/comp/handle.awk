
function comp_handle_exit( value, name, type ){
    if (name == "QUIT")                              panic()
    else if (name == U8WC_NAME_END_OF_TEXT)          panic("", 130)
    else if (name == U8WC_NAME_END_OF_TRANSIMISSION) panic()
}
