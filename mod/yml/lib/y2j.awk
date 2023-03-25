{
    # text = (text == "") ? $0 : ( text "\n" $0 )   
    text = text $0 "\n"
}

END{
    yml_parse( text, o )
    print jstr( o )
}

