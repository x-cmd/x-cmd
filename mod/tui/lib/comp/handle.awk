
function comp_handle_exit( value, name, type ){
    if (name == "QUIT")                              exit(0)
    else if (name == U8WC_NAME_END_OF_TEXT)          exit(0)
    else if (name == U8WC_NAME_END_OF_TRANSIMISSION) exit(0)
}
