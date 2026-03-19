BEGIN{
    Q2_1 = SUBSEP "\"1\""
}

{ jiparse_after_tokenize( o, $0 ) }

END{
    nl = o[ Q2_1 L ]
    if (nl <= 0) exit(1)

    printf("%s\n", "Name,Version,Quant,Format,Bits,Method,Size,Max-Ram-Required,Usecase,href")
    for (i=1; i<=nl; ++i){
        name = o[ Q2_1, i ]
        vl = o[ Q2_1, name L ]
        for (j=1; j<=vl; ++j){
            version = o[ Q2_1, name, j ]
            version_kp = Q2_1 SUBSEP name SUBSEP version
            ql = o[ version_kp L ]
            for (k=1; k<=ql; ++k){
                quant = o[ version_kp, k ]
                quant_kp = version_kp SUBSEP quant
                print llmf_get_content(o, quant_kp, name, version, quant)
            }
        }
    }
}

function llmf_get_content(o, kp, name, version, quant,              format, hf, bits, method, size, ram, usecase ){
    format  = llmf_csv_quote( o[ kp SUBSEP "\"format\"" ])
    hf      = llmf_csv_quote( o[ kp SUBSEP "\"hf\"" ])
    bits    = llmf_csv_quote( o[ kp SUBSEP "\"bits\"" ])
    method  = llmf_csv_quote( o[ kp SUBSEP "\"quant-method\"" ])
    size    = llmf_csv_quote( o[ kp SUBSEP "\"size\"" ])
    ram     = llmf_csv_quote( o[ kp SUBSEP "\"max-ram-required\"" ])
    usecase = llmf_csv_quote( o[ kp SUBSEP "\"usecase\"" ])

    name    = llmf_csv_quote(juq(name))
    version = llmf_csv_quote(juq(version))
    # name = llmf_csv_quote(juq(name) "/" juq(version) "/" juq(quant) "." juq(format) )
    return sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", name, version, quant, format, bits, method, size, ram, usecase, hf )
}

function llmf_csv_quote(s){
    if (s ~ "\"") s = juq(s)
    return csv_quote_ifmust(s)
}
