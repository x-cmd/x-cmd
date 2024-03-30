
BEGIN{
    model = ENVIRON[ "model" ]
    l = split(model, _, "/")
    if (l != 3) exit(1)
    name = _[1]
    version = _[2]
    quant = _[3]
    sub("\\..+$", "", quant)

    jiparse2leaf_fromfile( o, "",  dirpath "/" name ".json" )

    kp = SUBSEP "\"1\"" SUBSEP jqu(version) SUBSEP jqu(quant) SUBSEP "\"mmproj\""
    v = o[ kp ]
    if (v == "") exit(1)
    else print juq(v)
}
