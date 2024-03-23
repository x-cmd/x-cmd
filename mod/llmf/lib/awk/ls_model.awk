BEGIN{
    Q2_1 = SUBSEP "\"1\""
    IS_MMPROJ = ENVIRON[ "IS_MMPROJ" ]
}
{
    name = $0
    sub("\\.json$", "", name)
    jdict_put(o, Q2_1, jqu(name), "{")
    jiparse2leaf_fromfile( o, Q2_1 SUBSEP jqu(name),  dirpath "/" name ".json" )
}
END {
    l = o[ Q2_1 L ]

    for (i=1; i<=l; ++i){
        name = o[ Q2_1, i ]
        n = juq(name)
        vl = o[ Q2_1, name L ]
        for (j=1; j<=vl; ++j){
            version = o[ Q2_1, name, j ]
            v = juq(version)
            if (IS_MMPROJ == 1) { if (v !~ "mmproj") continue; }
            else if ( v ~ "mmproj" ) continue;

            ql = o[ Q2_1, name, version L ]
            for (k=1; k<=ql; ++k){
                quant = o[ Q2_1, name, version, k ]
                format = o[ Q2_1, name, version, quant, "\"format\"" ]
                print n "/" v "/" juq(quant) "." juq(format)
            }
        }
    }
}
