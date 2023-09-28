( $0 ~ "event:"){
    event = substr($0, 7)
    next
}
( $0 ~ "^data:" ){
    data = substr($0, 6)
    if (last_data_row == NR - 1) data = "\n" data
    last_data_row = NR
    content = content ( last_data = data )
    next
}
( $0 ~ "^meta:" ){
    meta = substr($0, 6)
    next
}


END{
    if (event != "finish")  exit(1)
    content = content "\n"
    jiparse_after_tokenize( o_meta, meta )

    KP_1 = S "\"1\""
    jdict_put(o_meta, KP_1, "\"choices\"", "[")
    jlist_put(o_meta, KP_1 S "\"choices\"", "{")
    KP_CHOICES_1 = KP_1 S "\"choices\"" S "\"1\""
    jdict_put(o_meta, KP_CHOICES_1, "\"role\"", "\"assistant\"")
    jdict_put(o_meta, KP_CHOICES_1, "\"content\"", jqu(content))

    print jstr0(o_meta)
}

