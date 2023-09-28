( $0 ~ "event:"){
    event = substr($0, 7)
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


END{
    if (event != "finish")  exit(1)
    printf "\n"
}

