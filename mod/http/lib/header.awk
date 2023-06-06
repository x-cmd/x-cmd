BEGIN{
    # application/json  # text, xml, yml
    # application/json;charset=utf-8

    code=""
    arrl = split(query, arr, ",")
    for (i=1; i<=arrl; ++i) {
        e = arr[i]
        if ((e ~ /(json)|(text)|(xml)|(yml)/)&&(e ~ /(application)/)){
            code = e
        }else{
            code = "application/" e
        }
    }

    for (i=1; i<=arrl; ++i) {
        e = arr[i]
        if (e ~ /(utf(-?8)*)/)                  code = code";charset=utf-8"
    }

    print code
}
