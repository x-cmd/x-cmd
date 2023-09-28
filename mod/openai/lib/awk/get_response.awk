function parse(s,       o){
    if (s ~ "^ *\\[DONE\\]$") exit(0)
    jiparse_after_tokenize(o, s)
    CONTENT = CONTENT juq(o[ KP_CONTENT ])
    if (RESPONSE[L] == "" ) clone( o, RESPONSE )
    if (o[ KP_FINISH_REASON ] == "\"stop\"") exit(0)
    JITER_LEVEL = JITER_CURLEN = 0
}

BEGIN{
    KP_1 = S "\"1\""
    KP_CHOICES_1 = KP_1 S "\"choices\"" S "\"1\""
    KP_FINISH_REASON = KP_CHOICES_1 S "\"finish_reason\""
    KP_MESSAGE = KP_CHOICES_1 S "\"message\""
    KP_DELTA = KP_CHOICES_1 S "\"delta\""
    KP_CONTENT = KP_DELTA S "\"content\""

}

( NR==1 && ($0 ~ "^{")){    exit(1);   }
( NR>1 && $0 != "" ){
    $1 = ""
    parse( $0 )
    fflush()
}

END{
    RESPONSE[ KP_FINISH_REASON ] = "\"stop\""
    jdict_put(RESPONSE, KP_CHOICES_1, "\"message\"")
    RESPONSE[ KP_CONTENT ] = jqu(CONTENT)
    cp_cover(RESPONSE, KP_MESSAGE, RESPONSE, KP_DELTA)
    jdict_rm(RESPONSE, KP_CHOICES_1, "\"delta\"")
    jdict_put(RESPONSE, KP_MESSAGE, "\"role\"", "\"assistant\"")
    print jstr0(RESPONSE)
}

