{
    # text = (text == "") ? $0 : ( text "\n" $0 )   
    text = text $0
    text = text "\n" #fix : some versions of mawk
}

END{
    yml_parse( text, o )
    print ystr( o )
}

