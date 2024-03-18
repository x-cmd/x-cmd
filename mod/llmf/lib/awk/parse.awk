BEGIN{
    Q2_1 = SUBSEP "\"1\""
    o[ L ] = 1
    o[ Q2_1 ] = "{"
}
{
    name = $0
    sub("\\.json$", "", name)
    name = jqu(name)
    jdict_put(o, Q2_1, name, "{")
    jiparse2leaf_fromfile( o, Q2_1 SUBSEP name,  dirpath "/" $0 )
}
END{
    print jstr(o)
}
