
BEGIN{
    L = "\001"
    result_dir = ENVIRON[ "result_dir" ]
}

{
    OLDFS=FS
    FS="\t"

    COUNT=0

    local_file = result_dir  "/" $1
    ruleid = $1
    gsub( ".tsv", "", ruleid )

    while ((c = (getline <local_file)) == 1) {
        if (COUNT++ == 0) continue
        target = $1
        score = $2
        hint = $3

        if ( info [ target, L ] < 1 ) {
            summary[ ++ summary[ L ] ] = target
            info[ target , L ] = 1
            info[ target , "score" ] = score
            info[ target , "rule" ] = ruleid
        } else {
            info[ target , L ] ++
            info[ target , "score" ] += score
            info[ target , "rule" ] = info[ target, "rule" ] " " ruleid
        }

        info[ target , "rule", L ] ++

        if ( score >= 81) {
            info[ target , "pass" ] = info[ target , "pass" ] ruleid " "
            info[ target , "pass", L ] ++
        } else {
            info[ target , "fail" ] = info[ target , "fail" ] ruleid " "
            info[ target , "fail", L ] ++
        }
    }

    FS=OLDFS
}

END{
    l = summary[ L ]
    printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n", "target", "avarge-score", "rule-count", "pass-rule-count", "fail-rule-count", "pass-rules", "fail-rules")

    for (i=1; i<=l; ++i) {
        target = summary[ i ]
        avg = int( info[ target, "score" ] / info[ target, L ] )

        printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\n",  target,     \
            avg,            \
            info[ target, "rule", L ],           \
            info[ target, "pass", L ], info[ target, "fail", L ], \
            info[ target, "pass" ],   info[ target, "fail" ]  )
    }
}
