BEGIN{
    GEMINI_CSV_HEADER = "Name,Description,SupportedGenerationMethods,inputTokenLimit,outputTokenLimit,temperature,topP,topK"
    GEMINI_HAD_HEADER = 0
}
($0 ~ "generateContent" ){
    method = juq(cval(3))
    len = split(method,arr,",")
    str= ""
    for(i=1; i<=len;++i){
        if(i < len) str = str juq(arr[i]) ","
        else        str = str juq(arr[i])
    }
    if ( GEMINI_HAD_HEADER == 0 ){
        print GEMINI_CSV_HEADER
        GEMINI_HAD_HEADER = 1
    }
    print substr(cval(1),index(cval(1),"/")+1)"," jqu(cval(2))","jqu(str)"," jqu(cval(4))","jqu(cval(5))","jqu(cval(6))","jqu(cval(7))","jqu(cval(8))
}
