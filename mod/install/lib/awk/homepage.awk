{ jiparse_after_tokenize( O, $0 ) }
END{
    print juq(O[SUBSEP "\"1\"" SUBSEP "\"homepage\""])
}
