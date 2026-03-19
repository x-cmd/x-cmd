{
    yml_text = yml_text $0
    yml_text = yml_text "\n" #fix : some versions of mawk
}

END{
    Q2_1 = SUBSEP "\"1\""
    yml_parse( yml_text, o )
    jmerge_soft___value( o, SUBSEP "\"1\"", o, SUBSEP  "\"2\"" )

    ystr(o, SUBSEP "\"1\"")
}