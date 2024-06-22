BEGIN{
    print "ID,SYMBOL,NAME"
}
{
    sym = juq(cval(2))
    len = split(sym,arr,",")
    str= ""
    for(i=1; i<=len;++i){
        if(i < len) str = str juq(arr[i]) ","
        else        str = str juq(arr[i])
    }
    print cval(1)","jqu(str)","jqu(cval(3))
}